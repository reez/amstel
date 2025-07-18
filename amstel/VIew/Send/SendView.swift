//
//  SendView.swift
//  amstel
//
//  Created by Robert Netzke on 7/7/25.
//
import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct SendView: View {
    var psbt: Psbt
    var walletState: WalletState

    @Binding var errorMessage: ErrorMessage?
    @Binding var activeFile: TaggedPsbt?

    @State var foreignRecipient: Recipient?
    @State var tx: BitcoinDevKit.Transaction?

    @State var waitingForBroadcast: Bool = false

    var body: some View {
        HStack {
            if let recipient = foreignRecipient {
                VStack {
                    Text("You are sending \(recipient.amount.toSat()) satoshis to")
                        .monospaced()
                        .padding()
                    AddressFormattedView(address: recipient.addr.description, columns: 4)
                        .padding()
                }
            } else {
                Text("You are sending coins to yourself")
                    .monospaced()
                    .padding()
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    activeFile = nil
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Send") {
                    waitingForBroadcast = true
                    sendTx()
                }
                .disabled(waitingForBroadcast)
            }
        }
        .onAppear {
            do {
                try extractTx()
            } catch let e {
                errorMessage = ErrorMessage(message: "\(e)")
                activeFile = nil
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .txDidSend)) { _ in
            #if DEBUG
                print("Transaction notification received")
            #endif
            activeFile = nil
        }
    }

    private func sendTx() {
        if let transaction = tx {
            do {
                try walletState.broadcastTx(transction: transaction)
            } catch {
                errorMessage = ErrorMessage(message: "Failed to broadcast. The node is not running.")
                activeFile = nil
            }
        }
    }

    private func extractTx() throws {
        let finalizeResult = psbt.finalize()
        if !finalizeResult.couldFinalize {
            errorMessage = ErrorMessage(message: "Could not finalize the PSBT. Does it have enough signatures?")
            activeFile = nil
        }
        let transaction = try finalizeResult.psbt.extractTx()
        for output in transaction.output() {
            if !walletState.isMine(output.scriptPubkey) {
                let foreignAddr = try! Address.fromScript(script: output.scriptPubkey, network: NETWORK)
                let foreignValue = output.value
                foreignRecipient = Recipient(addr: foreignAddr, amount: foreignValue)
            }
        }
        tx = transaction
    }
}
