//
//  SendViewModel.swift
//  amstel
//
//  Created by Robert Netzke on 7/7/25.
//

enum Flow: CaseIterable {
    case recipient, confirmRecipient, amount, confirmAmount, fee, review
    
    var index: Int {
        return Flow.allCases.firstIndex(of: self) ?? 0
    }

    static var totalSteps: Int {
        return Flow.allCases.count
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
