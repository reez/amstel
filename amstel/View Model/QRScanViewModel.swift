//
//  QRScanViewModel.swift
//  amstel
//
//  Created by Robert Netzke on 7/8/25.
//

import Foundation
import Combine

class QRScanViewModel: ObservableObject {
    @Published var scannedCode: String? = nil
}
