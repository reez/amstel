//
//  Notifications.swift
//  amstel
//
//  Created by Robert Netzke on 7/3/25.
//
import Foundation

extension Notification.Name {
    static let walletDidUpdate = Notification.Name("walletDidUpdate")
    static let progressDidUpdate = Notification.Name("progressDidUpdate")
    static let txDidSend = Notification.Name("txDidSend")
    static let txDidReject = Notification.Name("txDidReject")
}
