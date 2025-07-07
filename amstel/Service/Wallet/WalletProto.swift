//
//  Proto.swift
//  amstel
//
//  Created by Robert Netzke on 7/3/25.
//
import BitcoinDevKit
import Foundation

protocol WalletState {
    // Node lifecycle
    func start()
    func stop()
    // Wallet operations
    func balance() -> ViewableBalance
    func coins() -> [Coin]
    func transactions() -> [ViewableTransaction]
    func receive() throws -> ViewableAddress
    func completeTx(builder: TxBuilder) throws -> Psbt
    func broadcastTx(transction: Transaction) throws
    func isMine(_ script: Script) -> Bool
    // Node metrics
    func connected() -> Bool
    func fees() async -> FeeRates?
    func progress() -> Float
    func height() -> UInt32
    func isRunning() -> Bool
}

enum WalletStateError: Error {
    case notReady
}

final class UninitializedWallet: WalletState {
    func start() {}
    func stop() {}
    func balance() -> ViewableBalance { return ViewableBalance(bitcoin: 0, sats: 0) }
    func receive() throws -> ViewableAddress { throw WalletStateError.notReady }
    func completeTx(builder _: TxBuilder) throws -> Psbt { throw WalletStateError.notReady }
    func broadcastTx(transction _: Transaction) {}
    func isMine(_: Script) -> Bool { false }
    func coins() -> [Coin] { [] }
    func transactions() -> [ViewableTransaction] { [] }
    func fees() async -> FeeRates? { return nil }
    func connected() -> Bool { false }
    func progress() -> Float { 0 }
    func height() -> UInt32 { 0 }
    func isRunning() -> Bool { false }
}

#if DEBUG
    final class MockWallet: WalletState {
        func start() {}
        func stop() {}
        func balance() -> ViewableBalance { return ViewableBalance(bitcoin: 1, sats: 100_000_000) }
        func receive() throws -> ViewableAddress {
            ViewableAddress(
                address: "bc1qexampleaddress1234567890",
                uri: "bitcoin:bc1qexampleaddress1234567890",
                index: 0
            )
        }

        func completeTx(builder _: TxBuilder) throws -> Psbt { throw WalletStateError.notReady }
        func broadcastTx(transction _: Transaction) {}
        func coins() -> [Coin] {
            [Coin(index: 34,
                  txid: "aaaabbbbccccddddeeeeffffaaaabbbbccccddddeeeeffff",
                  script: "0P_0 OP_PUSHDATA20",
                  date: Date(),
                  sats: 21404,
                  change: false),
             Coin(index: 34,
                  txid: "aaaabbbbccccddddeeeeffffaaaabbbbccccddddeeeeffff",
                  script: "0P_0 OP_PUSHDATA20",
                  date: Date(),
                  sats: 21404,
                  change: true)]
        }

        func transactions() -> [ViewableTransaction] {
            [ViewableTransaction(netSend: false,
                                 amount: 4200,
                                 feeRate: nil,
                                 metadata: TxMetadata(txid: "aaaabbbbccccddddeeeeffffaaaabbbbccccddddeeeeffff", date: Date(), height: 402)),
             ViewableTransaction(netSend: true,
                                 amount: 3948,
                                 feeRate: nil,
                                 metadata: TxMetadata(txid: "aaaabbbbccccddddeeeeffffaaaabbbbccccddddeeeeffff", date: Date(), height: 3483))]
        }

        func isMine(_: Script) -> Bool { false }
        func fees() async -> FeeRates? { return FeeRates(minimum: 1, average: 4) }
        func connected() -> Bool { true }
        func progress() -> Float { 0.58 }
        func height() -> UInt32 { 42069 }
        func isRunning() -> Bool { true }
    }
#endif
