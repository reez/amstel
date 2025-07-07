//
//  Coin.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//
import BitcoinDevKit
import Foundation

struct Coin: Equatable, Hashable, Identifiable {
    let id: UUID = .init()
    let index: UInt32
    let txid: String
    let script: String
    let date: Date
    let sats: UInt64
    let change: Bool
}
