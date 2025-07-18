//
//  ContentView.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//

import BitcoinDevKit
import SwiftData
import SwiftUI
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [WalletItem]
    @AppStorage("sendNotif") private var notiesEnabled: Bool = false

    @State private var pendingImport: ImportFile?
    @State private var newWalletName = ""
    @State private var importDidError: Bool = false
    @State private var isShowingSettings: Bool = false
    @State private var isShowingImport: Bool = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        WalletView(item: item, keyClient: .live)
                            .id(item)
                    } label: {
                        Text("\(item.name)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(isPresented: $isShowingSettings)
            }
            .sheet(item: $pendingImport) { file in
                VStack(spacing: 20) {
                    Text("Name your wallet")
                        .font(.headline)
                    TextField("Wallet Name", text: $newWalletName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)

                    HStack {
                        Button("Cancel") {
                            pendingImport = nil
                            isShowingImport = false
                        }
                        Button("Import") {
                            let url = file.url
                            let importType = file.importType
                            do {
                                let importResponse = try importType.importNamedWalletFromFile(url, newWalletName)
                                let _ = try Wallet(recvId: importResponse.recvKeychainId,
                                                   recv: importResponse.recvDescriptor,
                                                   change: importResponse.changeDescriptor)
                                withAnimation {
                                    let newWallet = WalletItem(recvPath: importResponse.recvKeychainId, changePath: importResponse.changeKeychainId, name: newWalletName)
                                    modelContext.insert(newWallet)
                                }
                            } catch let e {
                                importDidError = true
                                #if DEBUG
                                    print("\(e)")
                                #endif
                            }
                            pendingImport = nil
                            isShowingImport = false
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .padding()
                .frame(width: 350)
            }
            .sheet(isPresented: $isShowingImport) {
                ImportSheetView(importFile: $pendingImport, isShowingImport: $isShowingImport)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { isShowingImport = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .keyboardShortcut("i", modifiers: [.command])
                }
                ToolbarItem {
                    Button(action: { isShowingSettings = true }) {
                        Label("Open Settings", systemImage: "gear")
                    }
                }
            }
            .popover(isPresented: $importDidError) {
                Text("There was an error importing your wallet")
                    .padding()
            }
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { _, error in
                    if let error = error {
                        #if DEBUG
                            print("Permission error: \(error.localizedDescription)")
                        #endif
                    } else {
                        notiesEnabled = true
                    }
                }
            }
        } detail: {
            VStack(spacing: 4) {
                Text("No wallet selected")
                    .padding()
                if items.isEmpty {
                    Text("Import a wallet with the top left toolbar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
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
