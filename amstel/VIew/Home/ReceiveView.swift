//
//  ReceiveView.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//
import SwiftUI
import QRCode

struct ReceiveView: View {
    let address: ViewableAddress

    var body: some View {
        VStack {
            // Don't add padding
            QRCodeViewUI(content: address.address,
                         onPixelShape: .curvePixel(),
                         eyeStyle: QRCode.EyeShape.RoundedRect(cornerRadiusFraction: 0.9) as? QRCodeFillStyleGenerator
            )
//            Text("\(address.address)")
//                .monospaced()
            // AddressFormattedView(address: address, columns: 4)
        }
    }
}

#Preview {
    ReceiveView(address: ViewableAddress(address:"bc1qexampleaddress1234567890", index: 0))
}
