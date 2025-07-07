//
//  RecipientView.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//
import AppKit
import BitcoinDevKit
import SwiftUI

struct RecipientView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel
    var walletState: WalletState
    @Binding var isPresented: Bool
    @Binding var errorMessage: ErrorMessage?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer()
            Text("Welcome to the transaction builder. Please start by adding a recipient. Once you have reviewed your transaction details, a PSBT file will be saved in the folder you select.")
                .font(.subheadline)
            Spacer()
            HStack {
                Button(action: {
                    do {
                        try pasteFromClip()
                    } catch {
                        errorMessage = ErrorMessage(message: "Invalid address")
                        isPresented = false
                    }
                }) {
                    Label("Paste", systemImage: "arrow.right.page.on.clipboard")
                }
                Button(action: {}) {
                    Label("Scan", systemImage: "qrcode")
                }
                Button(action: {
                    do {
                        try makeConsolidation()
                    } catch {
                        errorMessage = ErrorMessage(message: "Invalid address")
                        isPresented = false
                    }
                }) {
                    Label("Consolidate", systemImage: "bitcoinsign.arrow.trianglehead.counterclockwise.rotate.90")
                }
            }
            Spacer()
        }
        .frame(width: 300, height: 200)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    viewModel.step = .confirmRecipient
                }
                .disabled(viewModel.recipient == nil)
            }
        }
    }

    private func makeConsolidation() throws {
        let nextAddr = try walletState.receive()
        viewModel.isConsoldating = true
        viewModel.recipient = try Address(address: nextAddr.address, network: NETWORK)
    }

    private func pasteFromClip() throws {
        let pasteboard = NSPasteboard.general
        if let addr = pasteboard.string(forType: .string) {
            let addr = try Address(address: addr, network: NETWORK)
            if walletState.isMine(addr.scriptPubkey()) {
                viewModel.isConsoldating = true
            }
            viewModel.recipient = addr
        }
    }
}

#Preview {
    @Previewable @State var state: WalletState = UninitializedWallet()
    @Previewable @State var presented = true
    @Previewable @State var errorMessage: ErrorMessage? = nil
    RecipientView(viewModel: CreateTransactionViewModel(), walletState: state, isPresented: $presented, errorMessage: $errorMessage)
}
