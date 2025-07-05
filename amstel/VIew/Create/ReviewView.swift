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
    @Binding var walletState: WalletState
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Confirm your transaction")
                .font(.headline)
                .padding(.bottom, 4)
            if let amount = viewModel.value {
                if viewModel.isConsoldating {
                    Text("You are sending \(amount.toSat()) satoshis to yourself")
                        .monospaced()
                } else {
                    HStack {
                        Text("You are sending \(amount.toSat()) satoshis to")
                            .monospaced()
                            .padding(.bottom)
                        AddressFormattedView(address: viewModel.recipient!.description, columns: 4)
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
        .frame(width: 300, height: 100)
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
                                try buildAndSaveTx(builder: createTx, dirName: dirName, filename: filename)
                                isPresented = false
                            } catch {
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
    
    private func buildAndSaveTx(builder: TxBuilder, dirName: URL, filename: String) throws {
        var fileURL = dirName.appendingPathComponent(filename)
        let psbt = try walletState.completeTx(builder: builder)
        let encoded = psbt.serialize()
        // try encoded.write(to: &fileURL)
        return
    }
}
