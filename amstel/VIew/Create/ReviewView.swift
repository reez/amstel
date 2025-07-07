//
//  ReviewView.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//
import BitcoinDevKit
import SwiftUI

struct ReviewView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel
    var walletState: WalletState
    @Binding var isPresented: Bool
    @Binding var errorMessage: ErrorMessage?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let amount = viewModel.value {
                if viewModel.isConsoldating {
                    Text("You are sending \(amount.toSat()) satoshis to yourself")
                        .monospaced()
                } else {
                    VStack {
                        Text("You are sending \(amount.toSat()) satoshis to")
                            .monospaced()
                        AddressFormattedView(address: viewModel.recipient!.description, columns: 4)
                            .padding()
                    }
                }

            } else {
                if viewModel.isConsoldating {
                    Text("You are consolidating into a single coin")
                        .monospaced()
                } else {
                    Text("You are sending all of your coins to")
                        .monospaced()
                        .padding(.bottom)
                    AddressFormattedView(address: viewModel.recipient!.description, columns: 4)
                }
            }
        }
        .frame(width: 300, height: 200)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    promptUserForDirectory { url in
                        if let dirName = url {
                            let id = UUID().description
                            let filename = "transaction_\(id).psbt"
                            var createTx = TxBuilder()
                                .addGlobalXpubs()
                                .currentHeight(height: walletState.height())
                                .feeRate(feeRate: viewModel.feeRate)
                            if viewModel.drainingWallet {
                                createTx = createTx.drainTo(script: viewModel.recipient!.scriptPubkey()).drainWallet()
                            } else {
                                createTx = createTx.addRecipient(script: viewModel.recipient!.scriptPubkey(), amount: viewModel.value!)
                            }
                            do {
                                let filepath = dirName.appendingPathComponent(filename).path()
                                try buildAndSaveTx(builder: createTx, filepath: filepath)
                                isPresented = false
                            } catch let e {
                                errorMessage = ErrorMessage(message: e.localizedDescription)
                                isPresented = false
                            }
                        } else {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }

    func promptUserForDirectory(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose a folder"

        panel.begin { response in
            if response == .OK {
                completion(panel.url)
            } else {
                completion(nil)
            }
        }
    }

    private func buildAndSaveTx(builder: TxBuilder, filepath: String) throws {
        let psbt = try walletState.completeTx(builder: builder)
        try psbt.writeToFile(path: filepath)
    }
}

#Preview {
    @Previewable @State var walletState: WalletState = MockWallet()
    @Previewable @State var isPresented = true
    @Previewable @State var errorMessage: ErrorMessage? = nil
    ReviewView(viewModel: CreateTransactionViewModel(), walletState: walletState, isPresented: $isPresented, errorMessage: $errorMessage)
}
