//
//  AmountView.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//
import SwiftUI
import BitcoinDevKit

enum ParseFailed: Error {
    case invalid
}

struct AmountView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel
    @State var amountString: String = ""
    @Binding var walletState: WalletState
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("You have \(walletState.balance().sats) satoshis available")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)
            HStack {
                Picker("Denomination", selection: $viewModel.usingDenom) {
                    Text("Satoshis").tag(Denomination.sat)
                    Text("Bitcoin").tag(Denomination.btc)
                }
                .labelsHidden()
                TextField("", text: $amountString)
                    .labelsHidden()
                    .disableAutocorrection(true)
                    .frame(maxWidth: .infinity)
                    .onSubmit {
                        do {
                            try parseAmount()
                        } catch {
                            isPresented = false
                        }
                    }
            }
        }
        .frame(width: 300, height: 200)
        .toolbar {
            ToolbarItem {
                Button("Max") {
                    viewModel.drainingWallet = true
                    viewModel.step = .confirmAmount
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    viewModel.step = .confirmAmount
                }
                .disabled(viewModel.value == nil)
            }
        }
    }
    
    private func parseAmount() throws {
        let parsedAmountString = amountString.trimmingCharacters(in: .whitespacesAndNewlines)
        switch viewModel.usingDenom {
        case .btc:
            guard let btc = Double(parsedAmountString) else {
                throw ParseFailed.invalid
            }
            let amount = try Amount.fromBtc(btc: btc)
            viewModel.value = amount
        case .sat:
            guard let sat = UInt64(parsedAmountString) else {
                throw ParseFailed.invalid
            }
            viewModel.value = Amount.fromSat(satoshi: sat)
        }
    }
}

#Preview {
    @Previewable @State var walletState: WalletState = MockWallet()
    @Previewable @State var isPresented: Bool = true
    AmountView(viewModel: CreateTransactionViewModel(), amountString: "320432", walletState: $walletState, isPresented: $isPresented)
}
