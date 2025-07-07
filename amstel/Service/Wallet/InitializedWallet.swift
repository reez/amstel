//
//  InitializedWallet.swift
//  amstel
//
//  Created by Robert Netzke on 7/3/25.
//
import BitcoinDevKit
import Foundation

final class InitializedWallet: WalletState {
    private let wallet: Wallet
    private let client: CbfClient
    private let node: CbfNode
    private let persister: Persister
    private var isConnected: Bool = false
    private var currProgress: Float = 0.0
    private var currHeight: UInt32 = 0
    private var running: Bool = false
    private var failure: String = ""

    init(wallet: Wallet, client: CbfClient, node: CbfNode, persister: Persister) {
        self.wallet = wallet
        self.client = client
        self.node = node
        self.persister = persister
    }

    func balance() -> ViewableBalance { return wallet.balance().intoViewable() }

    func coins() -> [Coin] {
        wallet.listUnspent().map { $0.intoViewable() }
    }

    func receive() throws -> ViewableAddress {
        let addressInfo = wallet.revealNextAddress(keychain: .external)
        try client.addRevealedScripts(wallet: wallet)
        let _ = try wallet.persist(persister: persister)
        return addressInfo.intoViewable()
    }

    func isMine(_ script: Script) -> Bool {
        wallet.isMine(script: script)
    }

    func transactions() -> [ViewableTransaction] {
        let txs = wallet.transactions()
        var vals: [ViewableTransaction] = []
        for tx in txs {
            let metadata = tx.intoMetadata()
            let feeRate = try? wallet.calculateFeeRate(tx: tx.transaction)
            let sentAndReceived = wallet.sentAndReceived(tx: tx.transaction)
            let netSend = sentAndReceived.sent.toSat() > sentAndReceived.received.toSat()
            let amount = if netSend {
                sentAndReceived.sent.toSat() - sentAndReceived.received.toSat()
            } else {
                sentAndReceived.received.toSat() - sentAndReceived.sent.toSat()
            }
            let nextViewable = ViewableTransaction(netSend: netSend, amount: amount, feeRate: feeRate?.toSatPerVbCeil(), metadata: metadata)
            vals.append(nextViewable)
        }
        return vals
    }

    func completeTx(builder: TxBuilder) throws -> Psbt { return try builder.finish(wallet: wallet) }

    func broadcastTx(transction: Transaction) throws { try client.broadcast(transaction: transction) }

    func fees() async -> FeeRates? {
        let broadcastMin = try? await client.minBroadcastFeerate()
        let latestHash = wallet.latestCheckpoint().hash
        let lastBlockAverage = (try? await client.averageFeeRate(blockhash: latestHash)) ?? FeeRate.fromSatPerKwu(satKwu: 250)
        if let broadcastMin = broadcastMin {
            return FeeRates(minimum: broadcastMin.toSatPerVbCeil(), average: lastBlockAverage.toSatPerVbCeil())
        }
        return nil
    }

    func connected() -> Bool { isConnected }

    func progress() -> Float { currProgress }

    func height() -> UInt32 { currHeight }

    func isRunning() -> Bool { running }

    func start() {
        node.run()
        running = true
        handleLogs()
        handleWarnings()
        handleInfos()
        handleUpdates()
    }

    func stop() {
        let _ = try? client.shutdown()
    }

    private func handleLogs() {
        Task {
            while true {
                if let log = try? await self.client.nextLog() {
                    #if DEBUG
                        print(log)
                    #endif
                }
            }
        }
    }

    private func handleWarnings() {
        Task {
            while true {
                if let warn = try? await self.client.nextWarning() {
                    switch warn {
                    case .needConnections:
                        self.isConnected = false
                        await MainActor.run {
                            NotificationCenter.default.post(name: .progressDidUpdate, object: nil)
                        }
                    case .transactionRejected(wtxid: _, reason: _):
                        await MainActor.run {
                            NotificationCenter.default.post(name: .txDidReject, object: nil)
                        }
                    case let e:
                        #if DEBUG
                            print("\(e)")
                        #endif
                    }
                }
            }
        }
    }

    private func handleInfos() {
        Task {
            while true {
                if let info = try? await self.client.nextInfo() {
                    switch info {
                    case .connectionsMet:
                        await MainActor.run {
                            self.isConnected = true
                            NotificationCenter.default.post(name: .progressDidUpdate, object: nil)
                        }
                    case let .newChainHeight(height):
                        self.currHeight = height
                    case let .progress(progress):
                        await MainActor.run {
                            self.currProgress = progress
                            NotificationCenter.default.post(name: .progressDidUpdate, object: nil)
                        }
                    case let .txGossiped(wtxid: wtxid):
                        #if DEBUG
                            print("\(wtxid)")
                        #endif
                        await MainActor.run {
                            NotificationCenter.default.post(name: .txDidSend, object: nil)
                        }
                    case let e:
                        #if DEBUG
                            print("\(e)")
                        #endif
                    }
                }
            }
        }
    }

    private func handleUpdates() {
        Task {
            while true {
                if let update = try? await self.client.update() {
                    do {
                        try self.wallet.applyUpdate(update: update)
                        let _ = try self.wallet.persist(persister: self.persister)
                        await MainActor.run {
                            NotificationCenter.default.post(name: .walletDidUpdate, object: nil)
                        }
                    } catch let e {
                        self.failure = e.localizedDescription
                    }

                } else {
                    await MainActor.run {
                        self.isConnected = false
                        self.running = false
                        NotificationCenter.default.post(name: .progressDidUpdate, object: nil)
                    }
                }
            }
        }
    }

    private func extraBootstrap() {
        Task {
            let _ = await client.lookupHost(hostname: "seed.signet.bitcoin.sprovoost.nl")
        }
    }
}
