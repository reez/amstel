//
//  CreateTransactionView.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//

import SwiftUI
import BitcoinDevKit

enum AddressValidation {
    case unknown, valid, invalid
}

struct CreateTransactionView: View {
    @ObservedObject var viewModel = CreateTransactionViewModel()
    @Binding var walletState: WalletState
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            switch viewModel.step {
            case .recipient:
                RecipientView(viewModel: viewModel, walletState: $walletState, isPresented: $isPresented)
            case .confirmRecipient:
                ConfirmRecipientView(viewModel: viewModel)
            case .amount:
                AmountView(viewModel: viewModel, walletState: $walletState, isPresented: $isPresented)
            case .confirmAmount:
                ConfirmAmountView(viewModel: viewModel)
            case .fee:
                FeeSelectionView(viewModel: viewModel, walletState: $walletState, isPresented: $isPresented)
            case .review:
                ReviewView(viewModel: viewModel, walletState: $walletState, isPresented: $isPresented)
            }
        }
        .frame(width: 400, height: 200)
        .task {
            await getFees()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
        }
    }
    
    private func validateAddress(addr: String) -> Bool {
        switch NETWORK {
        case .bitcoin: addr.starts(with: "bcq1") || addr.starts(with: "bqtr")
        case .signet: addr.starts(with: "tb")
        default: false
        }
    }
    
    private func getFees() async {
        let fees = await walletState.fees()
        if let fees = fees {
            viewModel.expectedFeeRates = fees
        }
        viewModel.isFetchingFees = false
    }
}
