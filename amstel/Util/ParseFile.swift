//
//  ParseFile.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//
import BitcoinDevKit
import Foundation
import KeychainAccess

struct ImportResponse {
    var name: String
    var recvKeychainId: String
    var changeKeychainId: String
    var recvDescriptor: String
    var changeDescriptor: String
}

enum ImportTxtError: Error {
    case notMultipath
    case tooManyPaths
}

func importWalletFromTxtFile(from url: URL, withName name: String) throws -> ImportResponse {
    let contents = try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines)
    let descriptor = try Descriptor(descriptor: contents, network: NETWORK)
    if descriptor.isMultipath() {
        let descriptorList = try descriptor.toSingleDescriptors()
        if descriptorList.count != 2 {
            throw ImportTxtError.tooManyPaths
        }
        return try importFromTwoPath(descriptorList, name: name)
    } else {
        throw ImportTxtError.notMultipath
    }
}

func importFromBitcoinCoreJson(from url: URL, withName name: String) throws -> ImportResponse {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    
    if let single = try? decoder.decode(DescriptorImport.self, from: data) {
        let trimmed = single.desc.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = try Descriptor(descriptor: trimmed, network: NETWORK)
        if descriptor.isMultipath() {
            let descriptorList = try descriptor.toSingleDescriptors()
            if descriptorList.count != 2 {
                throw ImportBitcoinCoreError.tooManyDescriptors
            }
            return try importFromTwoPath(descriptorList, name: name)
        } else {
            throw ImportBitcoinCoreError.notMultipath
        }
    } else if let _ = try? decoder.decode([DescriptorImport].self, from: data) {
        throw ImportBitcoinCoreError.multipleDescriptorsNotSupported
    } else {
        throw ImportBitcoinCoreError.invalidFormat
    }
}

private func importFromTwoPath(_ descriptors: [Descriptor], name: String) throws -> ImportResponse {
    let descriptorOne = descriptors[0]
    let descriptorTwo = descriptors[1]
    let recvId = descriptorOne.descriptorId().description
    let changeId = descriptorTwo.descriptorId().description
    let recvBackup = Backup(keyId: recvId, descriptor: descriptorOne.description)
    let changeBackup = Backup(keyId: changeId, descriptor: descriptorTwo.description)
    let importData = KeychainImport(recv: recvBackup, change: changeBackup)
    try KeyClient.live.importKeys(importData)
    return ImportResponse(name: name,
                          recvKeychainId: recvId,
                          changeKeychainId: changeId,
                          recvDescriptor: descriptorOne.description,
                          changeDescriptor: descriptorTwo.description)
}
