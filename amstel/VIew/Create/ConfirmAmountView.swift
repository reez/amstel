//
//  ConfirmAmountView.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//

import SwiftUI
import BitcoinDevKit

struct ConfirmAmountView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if viewModel.drainingWallet && !viewModel.isConsoldating {
                Text("Send all your coins")
                    .font(.headline)
                    .fontWeight(.bold)
            } else if viewModel.drainingWallet {
                Text("Combine all coins")
                    .font(.headline)
                    .fontWeight(.bold)
            } else {
                Text("Confirm the amount")
                    .font(.headline)
                    .padding(.bottom, 4)
            }
            if let amount = viewModel.value {
                Text("\(amount.toSat()) satoshis")
                    .monospaced()
            }
        }
        .frame(width: 300, height: 100)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm") {
                    viewModel.step = .fee
                }
            }
        }
    }
}
