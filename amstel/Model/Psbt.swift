//
//  Psbt.swift
//  amstel
//
//  Created by Robert Netzke on 7/7/25.
//
import Foundation
import BitcoinDevKit

struct TaggedPsbt: Identifiable {
    let id: UUID = UUID()
    let psbt: Psbt
}
