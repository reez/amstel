//
//  Transaction.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//
import Foundation

struct ViewableTransaction: Equatable, Identifiable, Hashable {
    let id: UUID = .init()
    let netSend: Bool
    let amount: UInt64
    let feeRate: UInt64?
    let metadata: TxMetadata
}

struct TxMetadata: Equatable, Hashable {
    let txid: String
    let date: Date
    let height: UInt32
}
