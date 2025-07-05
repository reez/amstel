//
//  RecipientView.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//
import AppKit
import SwiftUI
import BitcoinDevKit

struct RecipientView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel
    @Binding var walletState: WalletState
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Button(action: {
                    do {
                        try pasteFromClip()
                    } catch {
                        isPresented = false
                    }
                }) {
                    Label("Paste", systemImage: "arrow.right.page.on.clipboard")
                }
                Button(action: {
                    
                }) {
                    Label("Scan", systemImage: "qrcode")
                }
                Button(action: {
                    do {
                        try makeConsolidation()
                    } catch {
                        isPresented = false
                    }
                }) {
                    Label("Consolidate", systemImage: "bitcoinsign.arrow.trianglehead.counterclockwise.rotate.90")
                }
            }
        }
        .frame(width: 300, height: 100)
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
            viewModel.recipient = try Address(address: addr, network: NETWORK)
        }
    }
}

#Preview {
    @Previewable @State var state: WalletState = UninitializedWallet()
    @Previewable @State var presented = true
    RecipientView(viewModel: CreateTransactionViewModel(), walletState: $state, isPresented: $presented)
}
