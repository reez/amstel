//
//  QRScannerView.swift
//  amstel
//
//  Created by Robert Netzke on 7/8/25.
//

import SwiftUI

struct QRScannerView: NSViewRepresentable {
    let coordinator: QRScannerCoordinator

    func makeNSView(context _: Context) -> NSView {
        let view = NSView()
        let previewLayer = coordinator.makePreviewLayer()
        previewLayer.frame = view.bounds
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]

        view.layer = CALayer()
        view.layer?.addSublayer(previewLayer)
        coordinator.session.startRunning()
        return view
    }

    func updateNSView(_: NSView, context _: Context) {}
}
