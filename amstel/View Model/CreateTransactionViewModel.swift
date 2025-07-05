//
//  CreateTransactionViewModel.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//
import SwiftUI
import BitcoinDevKit

enum Step {
    case recipient, confirmRecipient, amount, confirmAmount, fee, review
}

enum Denomination {
    case sat, btc
}

class CreateTransactionViewModel: ObservableObject {    
    @Published var step: Step = .recipient
    @Published var recipient: Address? = nil
    @Published var value: Amount? = nil
    @Published var feeRate: FeeRate = FeeRate.fromSatPerKwu(satKwu: 250)
    @Published var isConsoldating: Bool = false
    @Published var expectedFeeRates: FeeRates?
    @Published var isFetchingFees: Bool = false
    @Published var drainingWallet: Bool = false
    @Published var usingDenom: Denomination = .sat
}

