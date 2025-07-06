//
//  ContentView.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//

import SwiftUI
import SwiftData
import BitcoinDevKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [WalletItem]
    
    @State private var pendingFileURL: URL?
    @State private var isNamingWallet = false
    @State private var newWalletName = ""


    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        WalletView(item: item, keyClient: .live)
                    } label: {
                        Text("\(item.name)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .sheet(isPresented: $isNamingWallet) {
                VStack(spacing: 20) {
                    Text("Name your wallet")
                        .font(.headline)
                    TextField("Wallet Name", text: $newWalletName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)

                    HStack {
                        Button("Cancel") {
                            isNamingWallet = false
                            pendingFileURL = nil
                        }
                        Button("Import") {
                            if let url = pendingFileURL {
                                do {
                                    let importResponse = try importWalletFromTxtFile(from: url, withName: newWalletName)
                                    let _ = try Wallet.init(recvId: importResponse.recvKeychainId,
                                                    recv: importResponse.recvDescriptor,
                                                    change: importResponse.changeDescriptor)
                                    withAnimation {
                                        let newWallet = WalletItem(recvPath: importResponse.recvKeychainId, changePath: importResponse.changeKeychainId, name: newWalletName)
                                        modelContext.insert(newWallet)
                                    }
                                } catch let e {
                                    #if DEBUG
                                    print("\(e)")
                                    #endif
                                }
                            }
                            isNamingWallet = false
                            pendingFileURL = nil
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .padding()
                .frame(width: 350)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("No wallet selected")
        }
    }

    private func addItem() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.text]
        panel.canChooseDirectories = false
        panel.begin {
            response in
            if response == .OK, let url = panel.url {
                pendingFileURL = url
                isNamingWallet = true
                newWalletName = ""
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            let dirId = item.recvKeychainId
            let dirName = String.walletDirectoryPath(id: dirId)
            if FileManager.default.fileExists(atPath: dirName) {
                let _ = try? FileManager.default.removeItem(atPath: dirName)
            }
        }
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WalletItem.self, inMemory: true)
}
