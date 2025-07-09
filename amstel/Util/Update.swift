//
//  Notifications.swift
//  amstel
//
//  Created by Robert Netzke on 7/9/25.
//
import UserNotifications

func sendWalletUpdatedBanner() {
    let content = UNMutableNotificationContent()
    content.title = "Your wallet is synced"
    content.body = "Check your wallet for updates"

    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: nil
    )

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            #if DEBUG
            print("Failed to send notification: \(error.localizedDescription)")
            #endif
        }
    }
}
