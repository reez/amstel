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
        VStack(alignment: .leading, spacing: 4) {
            Spacer()
            Text("Select a fee")
                .font(.headline)
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
        .frame(width: 300, height: 100)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Review") {
                    viewModel.step = .review
                }
            }
        }
    }
}
