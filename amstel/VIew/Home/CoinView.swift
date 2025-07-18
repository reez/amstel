//
//  CoinView.swift
//  amstel
//
//  Created by Robert Netzke on 7/17/25.
//
import SwiftUI

struct CoinView: View {
    @Binding var coinBinding: Coin?
    let theCoin: Coin

    var body: some View {
        VStack(alignment: .leading) {
            Text("Coin Details")
                .font(.headline)
            Divider()
            Group {
                Text("\(theCoin.sats) sats")
                Divider()
                Text(theCoin.date.formatted(date: .long, time: .complete))
                Divider()
                Text("Derivation index: \(theCoin.change ? 1 : 0)/\(theCoin.index)")
                    .monospaced()
                    .foregroundStyle(.secondary)
                Divider()
                Text("TXID: \(theCoin.txid)")
                    .monospaced()
                    .foregroundStyle(.secondary)
                Divider()
                Text("Script size: \(theCoin.script)")
                    .monospaced()
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Dismiss") {
                    coinBinding = nil
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var coin: Coin? = Coin(index: 35, txid: "aaaaaabbbbbbccccccdddddd", script: "OP_0 OP_PUSHBYTES_20 AAAADDDDRRRREEEEQQQQ", date: Date(), sats: 120_213, change: false)
    CoinView(coinBinding: $coin, theCoin: coin!)
}
