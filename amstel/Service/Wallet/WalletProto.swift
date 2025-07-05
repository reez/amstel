//
//  Proto.swift
//  amstel
//
//  Created by Robert Netzke on 7/3/25.
//
import BitcoinDevKit

protocol WalletState {
    // Node lifecycle
    func start() -> Void
    func stop() -> Void
    // Wallet operations
    func balance() -> ViewableBalance
    func coins() -> [Coin]
    func transactions() -> [ViewableTransaction]
    func receive() throws -> ViewableAddress
    func completeTx(builder: TxBuilder) throws -> Psbt
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
    func start() -> Void { return }
    func stop() -> Void { return } 
    func balance() -> ViewableBalance { return ViewableBalance(bitcoin: 0, sats: 0) }
    func receive() throws -> ViewableAddress { throw WalletStateError.notReady }
    func completeTx(builder: TxBuilder) throws -> Psbt { throw WalletStateError.notReady }
    func coins() -> [Coin] { [] }
    func transactions() -> [ViewableTransaction] { [] }
    func fees() async -> FeeRates? { return nil }
    func connected() -> Bool { false }
    func progress() -> Float { 0 }
    func height() -> UInt32 { 0 }
    func isRunning() -> Bool { false }
}
