//
//  FeeSelectionView.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//
import SwiftUI
import BitcoinDevKit

struct FeeSelectionView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel
    @Binding var walletState: WalletState
    @Binding var isPresented: Bool
    @State var satPerVb: UInt64 = 1
    
    var body: some View {
        VStack(spacing: 4) {
            Spacer()
            if let expectedFeeRates = viewModel.expectedFeeRates {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "thermometer.low")
                            .foregroundStyle(.secondary)
                        Text("Minimum \(expectedFeeRates.minimum) sat/vB")
                            .monospaced()
                            .font(.subheadline)
                    }
                    HStack {
                        Image(systemName: "thermometer.high")
                            .foregroundStyle(.secondary)
                        Text("Last block average \(expectedFeeRates.average) sat/vB")
                            .monospaced()
                            .font(.subheadline)
                    }
                }
            } else {
                Text("Fee estimates unavailable")
                    .font(.subheadline)
                    .padding()
                
            }
            Spacer()
            Stepper(value: $satPerVb, in: 1...100, step: 1) {
                Text("Selected fee \(satPerVb) sat/vB")
            }
            Spacer()
        }
        .frame(width: 300, height: 200)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Review") {
                    viewModel.step = .review
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var walletState: WalletState = MockWallet()
    @Previewable @State var isPresented: Bool = true
    FeeSelectionView(viewModel: CreateTransactionViewModel(), walletState: $walletState, isPresented: $isPresented)
}
