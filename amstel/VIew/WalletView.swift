//
//  WalletView.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//
import BitcoinDevKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum Tab {
    case transactions
    case coins
}

struct WalletView: View {
    let item: WalletItem
    let keyClient: KeyClient

    @AppStorage("numConns") private var numConns: Int = 3
    @AppStorage("useProxy") private var useProxy: Bool = false
    @AppStorage("sendNotif") private var notiesEnabled: Bool = false

    @State private var walletState: WalletState = UninitializedWallet()
    // UI
    @State private var tab: Tab = .transactions
    @State private var isInitialLoad = true
    @State private var isCreatingTx = false
    @State private var errorMessage: ErrorMessage? = nil
    @State private var firstSync = false
    // Node attributes
    @State private var isConnected = false
    @State private var blockHeight: UInt32 = 0
    @State private var dead: Bool = false
    @State private var progress: Float = 0.0
    @State private var isInitialSync: Bool = true
    // Wallet attributes
    @State private var balance: ViewableBalance = .init(bitcoin: 0.0, sats: 0)
    @State private var coins: [Coin] = []
    @State private var transactions: [ViewableTransaction] = []
    @State private var currentRevealed: ViewableAddress? = nil
    // Files
    @State private var activeFile: TaggedPsbt? = nil
    @State private var isHoveringFile: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(balance.bitcoin) bitcoin")
                        .font(.title)
                    Text("\(balance.sats) satoshis")
                }
                Spacer()
                if isConnected {
                    Image(systemName: "network")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "network.slash")
                }
            }
            .padding()
            .opacity(isInitialLoad || errorMessage != nil ? 0 : 1)
            ProgressView(value: progress, total: 100.0)
                .padding()
            Picker("", selection: $tab) {
                Text("Transactions")
                    .tag(Tab.transactions)
                Text("Coins")
                    .tag(Tab.coins)
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .padding(.bottom)
            .padding(.leading)
            .padding(.trailing)
            Spacer()
            switch tab {
            case .transactions: TransactionListView(transactions: $transactions)
            case .coins: CoinListView(coins: $coins)
            }
            Spacer()
        }
        .toolbar {
            ToolbarItemGroup {
                Spacer()
                Button(action: {
                    isCreatingTx = true
                }) {
                    Label("Create", systemImage: "document.badge.plus.fill")
                }
                .keyboardShortcut("n", modifiers: [.command])
                .disabled(isInitialLoad || errorMessage != nil || isInitialSync)
                Button(action: {
                    if let url = openPsbtFile() {
                        do {
                            let psbt = try Psbt.fromFile(path: url.path())
                            activeFile = TaggedPsbt(psbt: psbt)
                        } catch {
                            errorMessage = ErrorMessage(message: "Could not parse the PSBT file")
                        }
                    }
                }) {
                    Label("Send", systemImage: "paperplane")
                }
                .keyboardShortcut("b", modifiers: [.command])
                Button(action: {
                    do {
                        self.currentRevealed = try self.walletState.receive()
                    } catch {
                        self.errorMessage = ErrorMessage(message: "Failed to save wallet data. To prevent address re-use, addresses cannot be revealed after a database failure.")
                        self.currentRevealed = nil
                    }
                }) {
                    Label("Recieve", systemImage: "qrcode")
                }
                .keyboardShortcut("r", modifiers: [.command])
                .disabled(isInitialLoad || errorMessage != nil || isInitialSync)
            }
        }
        // User flow sheets
        .sheet(item: $currentRevealed) { revealed in
            ReceiveView(addressActual: $currentRevealed, viewableAddress: revealed.address, uri: revealed.uri)
        }
        .sheet(isPresented: $isCreatingTx) {
            CreateTransactionView(walletState: walletState, isPresented: $isCreatingTx, errorMessage: $errorMessage)
        }
        .sheet(item: $activeFile) { file in
            SendView(psbt: file.psbt, walletState: walletState, errorMessage: $errorMessage, activeFile: $activeFile)
        }
        .sheet(item: $errorMessage) { message in
            ErrorView(message: $errorMessage, messageReadable: message.message)
        }
        .popover(isPresented: $firstSync) {
            Text("The first sync for a new import will take a while, anywhere between 10-60 minutes. Subsequent sync times will be much faster. Please leave the application open.")
                .padding()
        }
        // Handle notifications from the node
        .onReceive(NotificationCenter.default.publisher(for: .progressDidUpdate)) { _ in
            self.blockHeight = self.walletState.height()
            self.isConnected = self.walletState.connected()
            self.dead = !self.walletState.isRunning()
            self.progress = self.walletState.progress()
        }
        .onReceive(NotificationCenter.default.publisher(for: .walletDidUpdate)) { _ in
            if notiesEnabled {
                #if DEBUG
                print("Sending notification")
                #endif
                sendWalletUpdatedBanner()
            }
            self.isInitialSync = false
            self.firstSync = false
            self.blockHeight = self.walletState.height()
            self.isConnected = self.walletState.connected()
            self.dead = !self.walletState.isRunning()
            self.progress = 100.0
            self.balance = self.walletState.balance()
            self.coins = self.walletState.coins()
            self.transactions = self.walletState.transactions()
        }
        .onReceive(NotificationCenter.default.publisher(for: .txDidReject)) { _ in
            errorMessage = ErrorMessage(message: "Your transaction was rejected. Does it pay enough fees?")
        }
        .onAppear {
            do {
                try start()
                isInitialLoad = false
            } catch let e {
                errorMessage = ErrorMessage(message: e.localizedDescription)
            }
        }
        .onDisappear {
            walletState.stop()
        }
        // Gesture handling
        .onDrop(of: [.fileURL], isTargeted: $isHoveringFile) { providers in
            if let prov = providers.first {
                prov.loadItem(forTypeIdentifier: "public.file-url") { theFile, _ in
                    if let data = theFile as? Data {
                        if let url = URL(dataRepresentation: data, relativeTo: nil) {
                            let allowedExtensions = ["psbt"]
                            if allowedExtensions.contains(url.pathExtension.lowercased()) {
                                DispatchQueue.main.async {
                                    do {
                                        let psbt = try Psbt.fromFile(path: url.path())
                                        activeFile = TaggedPsbt(psbt: psbt)
                                    } catch {
                                        errorMessage = ErrorMessage(message: "Could not parse the PSBT file")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return true
        }
    }

    private func start() throws {
        let backup = try keyClient.getValues(KeyIds(recv: item.recvKeychainId, change: item.changeKeychainId))
        let path = String.walletSqliteFile(id: backup.recvId)
        let conn = try Persister.newSqlite(path: path)
        let recv = try Descriptor(descriptor: backup.recv, network: NETWORK)
        let change = try Descriptor(descriptor: backup.change, network: NETWORK)
        let wallet = try Wallet.load(descriptor: recv, changeDescriptor: change, persister: conn)
        let isRecovering = wallet.latestCheckpoint().height == 0
        if isRecovering {
            firstSync = true
        }
        let scanType = if isRecovering {
            ScanType.recovery(fromHeight: RECOVERY_HEIGHT)
        } else {
            ScanType.sync
        }
        if !FileManager.default.fileExists(atPath: URL.nodeDirectoryPath().path()) {
            try FileManager.default.createDirectory(at: URL.nodeDirectoryPath(), withIntermediateDirectories: false)
        }
        let conns = UInt8(numConns)
        var builder = CbfBuilder()
        if useProxy {
            builder = builder.socks5Proxy(proxy: TOR_PROXY)
        }
        let cbf = try builder
            .dataDir(dataDir: URL.nodeDirectoryPath().path())
            .scanType(scanType: scanType)
            .connections(connections: conns)
        #if DEBUG
            .peers(peers: [PEER_1, PEER_2, PEER_3])
        #endif
            .build(wallet: wallet)
        walletState = InitializedWallet(wallet: wallet, client: cbf.client, node: cbf.node, persister: conn)
        balance = walletState.balance()
        transactions = walletState.transactions()
        coins = walletState.coins()
        walletState.start()
    }

    private func openPsbtFile() -> URL? {
        let panel = NSOpenPanel()
        let extensionId = UTType(filenameExtension: "psbt") ?? .data
        panel.allowedContentTypes = [extensionId]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.title = "Select a PSBT"

        let response = panel.runModal()
        if response == .OK, let url = panel.url {
            return url
        } else {
            return nil
        }
    }
}

#Preview {
    let wallet = WalletItem.mock
    WalletView(item: wallet, keyClient: .mock)
}
