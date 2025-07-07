//
//  ConfirmRecipientView.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//

import BitcoinDevKit
import SwiftUI

struct ConfirmRecipientView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if viewModel.isConsoldating {
                Text("Combining coins")
                    .font(.headline)
                    .padding(.bottom, 4)
            } else {
                AddressFormattedView(address: viewModel.recipient!.description, columns: 4)
            }
        }
        .frame(width: 300, height: 200)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm") {
                    viewModel.step = .amount
                }
            }
        }
    }
}

#Preview {
    ConfirmRecipientView(viewModel: CreateTransactionViewModel())
}
