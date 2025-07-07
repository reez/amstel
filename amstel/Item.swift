//
//  Item.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//

import Foundation
import SwiftData

@Model
final class WalletItem {
    var recvKeychainId: String
    var changeKeychainId: String
    var name: String
    var createdAt: Date
    var airGap: Bool

    init(recvPath: String, changePath: String, name: String, timestamp: Date = Date(), airGap: Bool = true) {
        recvKeychainId = recvPath
        changeKeychainId = changePath
        self.name = name
        createdAt = timestamp
        self.airGap = airGap
    }
}

extension WalletItem {
    static let mock = WalletItem(recvPath: "", changePath: "", name: "Testable")
}
