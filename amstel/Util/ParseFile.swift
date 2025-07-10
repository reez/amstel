//
//  ParseFile.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//
import BitcoinDevKit
import Foundation
import KeychainAccess

enum InvalidFileExtension: Error {
    case unsupported
}

struct ImportResponse {
    var name: String
    var recvKeychainId: String
    var changeKeychainId: String
    var recvDescriptor: String
    var changeDescriptor: String
}

enum ImportError: Error {
    case notMultipath
    case tooManyPaths
}

struct ColdcardExport: Codable {
    let chain: String
    let xfp: String
    let bip86: ColdcardWallet?
}

struct ColdcardWallet: Codable {
    let name: String
    let desc: String
}

func importWalletFromTxtFile(from url: URL, withName name: String) throws -> ImportResponse {
    let contents = try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines)
    #if DEBUG
    print("=== TXT Import Debug ===")
    print("File contents: \(contents)")
    print("Network: \(NETWORK)")
    #endif
    let descriptor = try Descriptor(descriptor: contents, network: NETWORK)
    if descriptor.isMultipath() {
        let descriptorList = try descriptor.toSingleDescriptors()
        if descriptorList.count != 2 {
            throw ImportError.tooManyPaths
        }
        return try importFromTwoPath(descriptorList, name: name)
    } else {
        throw ImportError.notMultipath
    }
}

func importFromBitcoinCoreJson(from url: URL, withName name: String) throws -> ImportResponse {
    let data = try Data(contentsOf: url)
    #if DEBUG
    print("=== JSON Import Debug ===")
    if let jsonString = String(data: data, encoding: .utf8) {
        print("JSON contents: \(jsonString)")
    }
    print("Network: \(NETWORK)")
    #endif
    let decoder = JSONDecoder()

    if let single = try? decoder.decode(DescriptorImport.self, from: data) {
        let trimmed = single.desc.trimmingCharacters(in: .whitespacesAndNewlines)
        #if DEBUG
        print("Single descriptor found: \(trimmed)")
        #endif
        let descriptor = try Descriptor(descriptor: trimmed, network: NETWORK)
        if descriptor.isMultipath() {
            let descriptorList = try descriptor.toSingleDescriptors()
            if descriptorList.count != 2 {
                throw ImportError.tooManyPaths
            }
            return try importFromTwoPath(descriptorList, name: name)
        } else {
            throw ImportError.notMultipath
        }
    } else if let backs = try? decoder.decode([DescriptorImport].self, from: data) {
        var recvId: DescriptorId
        var changeId: DescriptorId
        var recvDescriptor: Descriptor
        var changeDescriptor: Descriptor
        
        if backs.count != 2 {
            throw ImportError.tooManyPaths
        }
        let backOne = backs[0]
        let trimmedOne = backOne.desc.trimmingCharacters(in: .whitespacesAndNewlines)
        #if DEBUG
        print("Descriptor 1: \(trimmedOne)")
        #endif
        let descriptorOne = try Descriptor(descriptor: trimmedOne, network: NETWORK)
        if descriptorOne.isMultipath() {
            throw ImportError.tooManyPaths
        }
        recvId = descriptorOne.descriptorId()
        recvDescriptor = descriptorOne
        let backTwo = backs[1]
        let trimmedTwo = backTwo.desc.trimmingCharacters(in: .whitespacesAndNewlines)
        #if DEBUG
        print("Descriptor 2: \(trimmedTwo)")
        #endif
        let descriptorTwo = try Descriptor(descriptor: trimmedTwo, network: NETWORK)
        if descriptorTwo.isMultipath() {
            throw ImportError.tooManyPaths
        }
        changeId = descriptorTwo.descriptorId()
        changeDescriptor = descriptorTwo
        let recvBackup = Backup(keyId: recvId.description, descriptor: recvDescriptor.description)
        let changeBackup = Backup(keyId: changeId.description, descriptor: changeDescriptor.description)
        let importData = KeychainImport(recv: recvBackup, change: changeBackup)
        try KeyClient.live.importKeys(importData)
        return ImportResponse(name: name,
                              recvKeychainId: recvId.description,
                              changeKeychainId: changeId.description,
                              recvDescriptor: descriptorOne.description,
                              changeDescriptor: descriptorTwo.description)
    } else if let coldcard = try? decoder.decode(ColdcardExport.self, from: data) {
        #if DEBUG
        print("Detected Coldcard export format")
        #endif
        if let bip86 = coldcard.bip86 {
            let trimmed = bip86.desc.trimmingCharacters(in: .whitespacesAndNewlines)
            #if DEBUG
            print("BIP86 descriptor: \(trimmed)")
            #endif
            let descriptor = try Descriptor(descriptor: trimmed, network: NETWORK)
            if descriptor.isMultipath() {
                let descriptorList = try descriptor.toSingleDescriptors()
                if descriptorList.count != 2 {
                    throw ImportError.tooManyPaths
                }
                return try importFromTwoPath(descriptorList, name: name)
            } else {
                throw ImportError.notMultipath
            }
        } else {
            throw ImportBitcoinCoreError.invalidFormat
        }
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
