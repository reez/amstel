//
//  BDK.swift
//  amstel
//
//  Created by Robert Netzke on 7/3/25.
//
import BitcoinDevKit
import Foundation

extension Balance {
    func intoViewable() -> ViewableBalance {
        let amount = self.total
        return ViewableBalance(bitcoin: amount.toBtc(), sats: amount.toSat())
    }
}

extension LocalOutput {
    func intoViewable() -> Coin {
        let val = self.txout.value
        let txid = self.outpoint.txid.description
        let index = self.derivationIndex
        let script = self.txout.scriptPubkey.toBytes().description
        let change = switch self.keychain {
        case .internal: true
        case .external: false
        }
        let (_, time) = switch self.chainPosition {
        case .confirmed(let confirmation_block_time, _):
            (confirmation_block_time.blockId.height, Date(timeIntervalSince1970: TimeInterval(confirmation_block_time.confirmationTime)))
        case .unconfirmed(_): (UInt32(0), Date())
        }
        return Coin(index: index, txid: txid, script: script, date: time, sats: val.toSat(), change: change)
    }
}

extension CanonicalTx {
    func intoMetadata() -> TxMetadata {
        let txid = self.transaction.computeTxid().description
        let (chainPos, time) = switch self.chainPosition {
        case .confirmed(let confirmation_block_time, _):
            (confirmation_block_time.blockId.height, Date(timeIntervalSince1970: TimeInterval(confirmation_block_time.confirmationTime)))
        case .unconfirmed(_): (UInt32(0), Date())
        }
        return TxMetadata(txid: txid, date: time, height: chainPos)
    }
}

extension AddressInfo {
    func intoViewable() -> ViewableAddress {
        let address = self.address.description
        let index = self.index
        return ViewableAddress(address: address, index: index)
    }
}

extension String {
    static func walletDirectoryPath(id: String) -> String {
        let documentsDir = URL.documentsDirectory
        let walletDir = documentsDir.appendingPathComponent(id)
        return walletDir.path()
    }
    
    static func walletSqliteFile(id: String) -> String {
        let documentsDir = URL.documentsDirectory
        let walletDir = documentsDir.appendingPathComponent(id)
        return walletDir.appendingPathComponent("wallet.db").path()
    }
}

extension Wallet {
    convenience init(recvId: String, recv: String, change: String) throws {
        let docsDir = URL.documentsDirectory
        try FileManager.default.createDirectory(at: docsDir.appendingPathComponent(recvId), withIntermediateDirectories: false)
        let recv = try Descriptor(descriptor: recv, network: NETWORK)
        let change = try Descriptor(descriptor: change, network: NETWORK)
        let conn = try Persister.newSqlite(path: String.walletSqliteFile(id: recvId))
        try self.init(descriptor: recv, changeDescriptor: change, network: NETWORK, persister: conn)
        let _ = try self.persist(persister: conn)
    }
}
