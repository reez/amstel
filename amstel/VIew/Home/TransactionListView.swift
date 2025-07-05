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
                    Image(systemName: tx.netSend ? "arrow.up.right" : "arrow.down.left")
                        .foregroundColor(tx.netSend ? .red : .green)
                        .font(.subheadline)
                }
                // Middle
                HStack {
                    Text(tx.metadata.date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
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
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var transaction: [ViewableTransaction] = [
        ViewableTransaction(netSend: false,
                            amount: 4200,
                            metadata: TxMetadata(txid: "aaaabbbbccccddddeeeeffffaaaabbbbccccddddeeeeffff", date: Date(), height: 402)
                           ),
        ViewableTransaction(netSend: true,
                            amount: 3948,
                            metadata: TxMetadata(txid: "aaaabbbbccccddddeeeeffffaaaabbbbccccddddeeeeffff", date: Date(), height: 3483)
                           )
    ]
    TransactionListView(transactions: $transaction)
}
