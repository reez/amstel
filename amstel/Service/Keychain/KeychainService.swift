//
//  KeychainService.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//
import Foundation
import KeychainAccess

struct Backup {
    var keyId: String
    var descriptor: String
}

struct KeychainImport {
    var recv: Backup
    var change: Backup
}

struct KeyIds {
    var recv: String
    var change: String
}

struct Values {
    var recv: String
    var change: String
    var recvId: String
}

enum KeychainError: Error {
    case notFound
}

private struct KeychainService {
    private let keychain: Keychain

    init() {
        let keychain = Keychain(service: "com.robertnetzke.amstel.keychain")
            .label(Bundle.main.bundlePath)
            .synchronizable(false)
            .accessibility(.whenUnlockedThisDeviceOnly)
        self.keychain = keychain
    }

    func importKeys(importData: KeychainImport) throws {
        keychain[importData.recv.keyId] = importData.recv.descriptor
        keychain[importData.change.keyId] = importData.change.descriptor
    }

    func getValues(ids: KeyIds) throws -> Values {
        guard let recvDescriptor = keychain[ids.recv] else {
            throw KeychainError.notFound
        }
        guard let changeDescriptor = keychain[ids.change] else {
            throw KeychainError.notFound
        }
        return Values(recv: recvDescriptor, change: changeDescriptor, recvId: ids.recv)
    }
}

struct KeyClient {
    let importKeys: (KeychainImport) throws -> Void
    let getValues: (KeyIds) throws -> Values

    private init(
        importKeys: @escaping (KeychainImport) throws -> Void,
        getValues: @escaping (KeyIds) throws -> Values
    ) {
        self.importKeys = importKeys
        self.getValues = getValues
    }
}

extension KeyClient {
    static let live = Self(
        importKeys: { importData in try KeychainService().importKeys(importData: importData) },
        getValues: { keyIds in try KeychainService().getValues(ids: keyIds) }
    )
}

#if DEBUG
    extension KeyClient {
        static let mock = Self(
            importKeys: { _ in },
            getValues: { _ in Values(recv: SIGNET_RECV, change: SIGNET_CHANGE, recvId: "") }
        )
    }
#endif
