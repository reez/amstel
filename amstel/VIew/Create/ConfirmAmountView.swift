//
//  ConfirmAmountView.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//

import BitcoinDevKit
import SwiftUI

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
            }
            if let amount = viewModel.value {
                Text("\(amount.toSat()) satoshis")
                    .monospaced()
            }
        }
        .frame(width: 300, height: 200)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm") {
                    viewModel.step = .fee
                }
            }
        }
    }
}

#Preview {
    var viewModel = CreateTransactionViewModel()
    ConfirmAmountView(viewModel: viewModel)
}
