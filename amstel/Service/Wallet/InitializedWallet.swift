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
        let addressInfo = self.wallet.revealNextAddress(keychain: .external)
        try self.client.addRevealedScripts(wallet: self.wallet)
        let _ = try self.wallet.persist(persister: self.persister)
        return addressInfo.intoViewable()
    }
    
    func transactions() -> [ViewableTransaction] {
        let txs = self.wallet.transactions()
        var vals: [ViewableTransaction] = []
        for tx in txs {
            let metadata = tx.intoMetadata()
            let _feeRate = try? self.wallet.calculateFeeRate(tx: tx.transaction)
            let sentAndReceived = self.wallet.sentAndReceived(tx: tx.transaction)
            let netSend = sentAndReceived.sent.toSat() > sentAndReceived.received.toSat()
            let amount = if netSend {
                sentAndReceived.sent.toSat() - sentAndReceived.received.toSat()
            } else {
                sentAndReceived.received.toSat() - sentAndReceived.sent.toSat()
            }
            let nextViewable = ViewableTransaction(netSend: netSend, amount: amount, metadata: metadata)
            vals.append(nextViewable)
        }
        return vals
    }
    
    func completeTx(builder: TxBuilder) throws -> Psbt { return try builder.finish(wallet: self.wallet) }
    
    func fees() async -> FeeRates? {
        let broadcastMin = try? await self.client.minBroadcastFeerate()
        if let broadcastMin = broadcastMin {
            return FeeRates(minimum: broadcastMin.toSatPerVbCeil(), average: broadcastMin.toSatPerVbCeil())
        }
        return nil
    }
    
    func connected() -> Bool { self.isConnected }
    
    func progress() -> Float { self.currProgress }
    
    func height() -> UInt32 { self.currHeight }
    
    func isRunning() -> Bool { self.running }
    
    func start() -> Void {
        self.node.run()
        self.running = true
        self.handleLogs()
        self.handleWarnings()
        self.handleInfos()
        self.handleUpdates()
    }
    
    func stop() -> Void {
        let _ = try? self.client.shutdown()
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
                    case .newChainHeight(let height):
                        self.currHeight = height
                    case .progress(let progress):
                        await MainActor.run {
                            self.currProgress = progress
                            NotificationCenter.default.post(name: .progressDidUpdate, object: nil)
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
