//
//  SettingsView.swift
//  amstel
//
//  Created by Robert Netzke on 7/8/25.
//
import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @AppStorage("numConns") private var numConns: Int = 3
    @AppStorage("useProxy") private var useProxy: Bool = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Stepper(value: $numConns, in: 1...10) {
                            Text("")
                        }
                        .labelsHidden()
                        Text("Connections \(numConns)")
                    }
                    VStack(alignment: .leading) {
                        Toggle("Tor proxy", isOn: $useProxy)
                        Text("Route connections through a Tor proxy hosted at 127.0.0.1:9050")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Dismiss") {
                    isPresented = false
                }
            }
        }
        .padding()
        .frame(width: 300)
        .navigationTitle("Settings")
    }
}

#Preview {
    @Previewable @State var isPresented = true
    SettingsView(isPresented: $isPresented)
}

