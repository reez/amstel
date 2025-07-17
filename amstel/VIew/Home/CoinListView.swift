//
//  CoinListView.swift
//  amstel
//
//  Created by Robert Netzke on 7/4/25.
//

import Foundation
import SwiftUI

struct CoinListView: View {
    @Binding var coins: [Coin]
    @State var selectedCoin: Coin?

    var body: some View {
        List(coins) { coin in
            VStack(alignment: .leading, spacing: 4) {
                // Top
                HStack {
                    Text(coin.date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(coin.sats) sats")
                        .font(.subheadline)
                        .monospaced()
                }
                // Middle
                HStack {
                    Spacer()
                    Text("\(coin.change ? 1 : 0)/\(coin.index)")
                        .font(.caption2)
                        .monospaced()
                        .foregroundStyle(.secondary)
                }
                // End
                HStack {
                    if coin.change {
                        Text("Change")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Received")
                            .font(.caption2)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedCoin = coin
            }
        }
        .sheet(item: $selectedCoin) { coin in
            CoinView(coinBinding: $selectedCoin, theCoin: coin)
        }
    }
}

#Preview {
    @Previewable @State var coins: [Coin] = [Coin(index: 34,
                                                  txid: "aaaabbbbccccddddeeeeffffaaaabbbbccccddddeeeeffff",
                                                  script: "0P_0 OP_PUSHDATA20",
                                                  date: Date(),
                                                  sats: 21404,
                                                  change: false),
                                             Coin(index: 34,
                                                  txid: "aaaabbbbccccddddeeeeffffaaaabbbbccccddddeeeeffff",
                                                  script: "0P_0 OP_PUSHDATA20",
                                                  date: Date(),
                                                  sats: 21404,
                                                  change: true)]
    CoinListView(coins: $coins)
}
