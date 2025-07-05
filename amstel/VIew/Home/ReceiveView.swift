//
//  ReceiveView.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//
import SwiftUI
import QRCode

struct ReceiveView: View {
    @Binding var addressActual: ViewableAddress?
    let viewableAddress: String

    var body: some View {
        VStack {
            // Don't add padding
            QRCodeViewUI(content: viewableAddress,
                         onPixelShape: .curvePixel(),
                         eyeStyle: QRCode.EyeShape.RoundedRect(cornerRadiusFraction: 0.9) as? QRCodeFillStyleGenerator
            )
            .padding()
            AddressFormattedView(address: viewableAddress, columns: 4)
                .font(.subheadline)
                .padding()
        }
        .padding()
        .frame(width: 450, height: 450)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(viewableAddress, forType: .string)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    addressActual = nil
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var addressActual: ViewableAddress? = ViewableAddress(address:"bc1qexampleaddress1234567890", index: 0)
    ReceiveView(addressActual: $addressActual, viewableAddress: "bc1qexampleaddress1234567890")
}
