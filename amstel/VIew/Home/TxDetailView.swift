//
//  TxDetailView.swift
//  amstel
//
//  Created by Robert Netzke on 7/17/25.
//
import SwiftUI

struct TxDetailView: View {
    @Binding var txBinding: ViewableTransaction?
    let theTx: ViewableTransaction

    var body: some View {
        VStack(alignment: .leading) {
            Text("Transaction Details")
                .font(.headline)
            Divider()
            Group {
                Text("You \(theTx.netSend ? "sent " : "received ")\(theTx.amount) sats")
                Divider()
                Text(theTx.metadata.date.formatted(date: .long, time: .complete))
                Divider()
                Text("TXID: \(theTx.metadata.txid)")
                    .monospaced()
                    .foregroundStyle(.secondary)
//                Divider()
//                Text("Script size: \(theCoin.script)")
//                    .monospaced()
//                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Dismiss") {
                    txBinding = nil
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var theTx: ViewableTransaction? = ViewableTransaction(netSend: true,
                                                                              amount: 322,
                                                                              feeRate: 1,
                                                                              metadata: TxMetadata(txid: "aaaabbbbccccddddeeeeffffaaaabbbbccccddddeeeeffff",
                                                                                                   date: Date(), height: nil))
    TxDetailView(txBinding: $theTx, theTx: theTx!)
}
