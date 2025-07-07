//
//  Psbt.swift
//  amstel
//
//  Created by Robert Netzke on 7/7/25.
//
import BitcoinDevKit
import Foundation

struct TaggedPsbt: Identifiable {
    let id: UUID = .init()
    let psbt: Psbt
}
