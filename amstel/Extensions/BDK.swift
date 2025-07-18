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
        let amount = total
        return ViewableBalance(bitcoin: amount.toBtc(), sats: amount.toSat())
    }
}

extension LocalOutput {
    func intoViewable() -> Coin {
        let val = txout.value
        let txid = outpoint.txid.description
        let index = derivationIndex
        let script = txout.scriptPubkey.toBytes().description
        let change = switch keychain {
        case .internal: true
        case .external: false
        }
        let (_, time) = switch chainPosition {
        case let .confirmed(confirmation_block_time, _):
            (confirmation_block_time.blockId.height, Date(timeIntervalSince1970: TimeInterval(confirmation_block_time.confirmationTime)))
        case .unconfirmed: (UInt32(0), Date())
        }
        return Coin(index: index, txid: txid, script: script, date: time, sats: val.toSat(), change: change)
    }
}

extension CanonicalTx {
    func intoMetadata() -> TxMetadata {
        let txid = transaction.computeTxid().description
        let (chainPos, time): (UInt32?, Date) = switch chainPosition {
        case let .confirmed(confirmation_block_time, _):
            (confirmation_block_time.blockId.height, Date(timeIntervalSince1970: TimeInterval(confirmation_block_time.confirmationTime)))
        case .unconfirmed: (nil, Date())
        }
        return TxMetadata(txid: txid, date: time, height: chainPos)
    }
}

extension AddressInfo {
    func intoViewable() -> ViewableAddress {
        let address = self.address.description
        let index = self.index
        let uri = self.address.toQrUri()
        return ViewableAddress(address: address, uri: uri, index: index)
    }
}

extension String {
    static func walletDirectoryPath(id: String) -> String {
        return URL.walletDirectoryUrl(id: id).path()
    }

    static func walletSqliteFile(id: String) -> String {
        let walletDir = URL.walletDirectoryUrl(id: id)
        return walletDir.appendingPathComponent("wallet.db").path()
    }
}

extension URL {
    static func baseApplicationUrl() -> URL {
        let appSupport = URL.libraryDirectory
        let application = appSupport.appendingPathComponent("Amstel")
        return application
    }

    static func nodeDirectoryPath() -> URL {
        let base = URL.baseApplicationUrl()
        let nodeDir = base.appendingPathComponent(".node")
        return nodeDir
    }

    static func walletDirectoryUrl(id: String) -> URL {
        let base = URL.baseApplicationUrl()
        let walletDir = base.appendingPathComponent(id)
        return walletDir
    }
}

extension Wallet {
    convenience init(recvId: String, recv: String, change: String) throws {
        let walletDir = URL.walletDirectoryUrl(id: recvId)
        try FileManager.default.createDirectory(at: walletDir, withIntermediateDirectories: true)
        let recv = try Descriptor(descriptor: recv, network: NETWORK)
        let change = try Descriptor(descriptor: change, network: NETWORK)
        let conn = try Persister.newSqlite(path: String.walletSqliteFile(id: recvId))
        try self.init(descriptor: recv, changeDescriptor: change, network: NETWORK, persister: conn)
        _ = try persist(persister: conn)
    }
}
