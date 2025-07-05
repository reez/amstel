//
//  ConfirmRecipientView.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//

import SwiftUI
import BitcoinDevKit

struct ConfirmRecipientView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if viewModel.isConsoldating {
                Text("Combining coins")
                    .font(.headline)
                    .padding(.bottom, 4)
            } else {
                Text("Confirm your destination")
                    .font(.headline)
                    .padding(.bottom, 4)
            }
            Text("\(viewModel.recipient!.description)")
                .monospaced()
        }
        .frame(width: 300, height: 100)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm") {
                    viewModel.step = .amount
                }
            }
        }
    }
}
