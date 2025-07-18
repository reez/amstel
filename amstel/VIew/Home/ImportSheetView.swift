//
//  ImportSheet.swift
//  amstel
//
//  Created by Robert Netzke on 7/17/25.
//
import SwiftUI

struct ImportSheetView: View {
    @Binding var importFile: ImportFile?
    @Binding var isShowingImport: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose Import")
                .font(.headline)
            Divider()
            ForEach(ImportType.allCases) { type in
                Button {
                    addItem(importType: type)
                } label: {
                    HStack {
                        type.systemImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.accentColor)
                            .padding()
                        VStack(alignment: .leading) {
                            Text(type.label)
                                .font(.headline)
                            Text(type.fileDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(nil)
                        }
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
                .padding()
                Divider()
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Dismiss") {
                    isShowingImport = false
                }
            }
        }
    }

    private func addItem(importType: ImportType) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.text]
        panel.canChooseDirectories = false
        panel.begin {
            response in
            if response == .OK, let url = panel.url {
                importFile = ImportFile(url: url, importType: importType)
            }
        }
    }
}
