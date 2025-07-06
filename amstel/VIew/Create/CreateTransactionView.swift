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
        VStack(alignment: .leading) {
            Text("\(viewModel.step.title)")
                .font(.headline)
            ProgressView(
                         value: Double(viewModel.step.index + 1),
                         total: Double(Step.totalSteps)
            )
            .labelsHidden()
            HStack {
                Spacer()
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
                Spacer()
            }
        }
        .frame(width: 400, height: 250)
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
    
    private func getFees() async {
        let fees = await walletState.fees()
        if let fees = fees {
            viewModel.expectedFeeRates = fees
        }
        viewModel.isFetchingFees = false
    }
}

#Preview {
    @Previewable @State var walletState: WalletState = MockWallet()
    @Previewable @State var isPresented: Bool = true
    CreateTransactionView(viewModel: CreateTransactionViewModel(), walletState: $walletState, isPresented: $isPresented)
}
