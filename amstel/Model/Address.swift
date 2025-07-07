//
//  Address.swift
//  amstel
//
//  Created by Robert Netzke on 7/4/25.
//

import Foundation

struct ViewableAddress: Identifiable {
    let id: UUID = .init()
    let address: String
    let uri: String
    let index: UInt32
}
