//
//  CoinView.swift
//  amstel
//
//  Created by Robert Netzke on 7/4/25.
//

import SwiftUI
import Foundation

struct CoinListView: View {
    @Binding var coins: [Coin]

    var body: some View {
        List(coins) { coin in
            VStack(alignment: .leading, spacing: 4) {
                // Top
                HStack {
                    Text("TXID: \(coin.txid)")
                        .font(.subheadline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(.secondary)
                        .monospaced()
                    Spacer()
                    Text("\(coin.sats) sats")
                        .font(.subheadline)
                        .monospaced()
                }
                // Middle
                HStack {
                    Spacer()
                    if coin.change {
                        Text("Change")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    } else {
                        Text("Received")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
                // End
                HStack {
                    Text("Index \(coin.index)")
                        .font(.caption2)
                        .monospaced()
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(coin.date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

