//
//  QRScanViewModel.swift
//  amstel
//
//  Created by Robert Netzke on 7/8/25.
//

import Combine
import Foundation

class QRScanViewModel: ObservableObject {
    @Published var scannedCode: String? = nil
}
