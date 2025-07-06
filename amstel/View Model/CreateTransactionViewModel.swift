//
//  CreateTransactionViewModel.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//
import SwiftUI
import BitcoinDevKit

enum Step: CaseIterable {
    case recipient, confirmRecipient, amount, confirmAmount, fee, review
    
    var index: Int {
        return Step.allCases.firstIndex(of: self) ?? 0
    }

    static var totalSteps: Int {
        return Step.allCases.count
    }
    
    var title: String {
        switch self {
        case .recipient:
            return "Add Recipient"
        case .confirmRecipient:
            return "Confirm Recipient"
        case .amount:
            return "Enter Amount"
        case .confirmAmount:
            return "Confirm Amount"
        case .fee:
            return "Set Fee"
        case .review:
            return "Review Transaction"
        }
    }
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

