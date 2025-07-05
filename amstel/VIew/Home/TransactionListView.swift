//
//  TransactionListView.swift
//  amstel
//
//  Created by Robert Netzke on 7/4/25.
//
import SwiftUI
import Foundation

struct TransactionListView: View {
    @Binding var transactions: [ViewableTransaction]
    
    var body: some View {
        List(transactions) { tx in
            VStack(alignment: .leading, spacing: 4) {
                // Top
                HStack {
                    Text("TXID: \(tx.metadata.txid)")
                        .font(.subheadline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(.secondary)
                        .monospaced()
                    Spacer()
                    Label(tx.netSend ? "Sent" : "Received",
                          systemImage: tx.netSend ? "arrow.up.right" : "arrow.down.left")
                        .foregroundColor(tx.netSend ? .red : .green)
                        .font(.subheadline)
                }
                // Middle
                HStack {
//                    Image(systemName: "clock")
//                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(tx.amount) sats")
                        .monospaced()
                        .font(.subheadline)
                }
                // Bottom
                HStack {
                    Text("Block \(tx.metadata.height)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(tx.metadata.date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
