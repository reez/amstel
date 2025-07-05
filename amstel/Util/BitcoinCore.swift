//
//  BitcoinCore.swift
//  amstel
//
//  Created by Robert Netzke on 7/5/25.
//

import Foundation

enum ImportBitcoinCoreError: Error {
    case multipleDescriptorsNotSupported, tooManyDescriptors, notMultipath, invalidFormat
}

struct DescriptorImport: Codable {
    let desc: String
    let active: Bool?
    let range: RangeOrInt?
    let nextIndex: Int?
    let timestamp: Timestamp
    let internalUse: Bool?
    let label: String?

    enum CodingKeys: String, CodingKey {
        case desc
        case active
        case range
        case nextIndex = "next_index"
        case timestamp
        case internalUse = "internal"
        case label
    }
}

enum Timestamp: Codable {
    case now
    case seconds(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .seconds(intVal)
        } else if let strVal = try? container.decode(String.self), strVal.lowercased() == "now" {
            self = .now
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid timestamp format")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .now:
            try container.encode("now")
        case .seconds(let value):
            try container.encode(value)
        }
    }
}

enum RangeOrInt: Codable {
    case single(Int)
    case range([Int])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .single(intVal)
        } else if let arrayVal = try? container.decode([Int].self) {
            self = .range(arrayVal)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid range format")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let value):
            try container.encode(value)
        case .range(let values):
            try container.encode(values)
        }
    }
}
