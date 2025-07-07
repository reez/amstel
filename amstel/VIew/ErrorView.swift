//
//  Error.swift
//  amstel
//
//  Created by Robert Netzke on 7/7/25.
//
import SwiftUI

struct ErrorView: View {
    @Binding var message: ErrorMessage?
    var messageReadable: String
    
    var body: some View {
        VStack {
            Text("\(messageReadable)")
                .padding()
        }
        .frame(width: 300, height: 150)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Dismiss") {
                    message = nil
                }
            }
        }
    }
}

