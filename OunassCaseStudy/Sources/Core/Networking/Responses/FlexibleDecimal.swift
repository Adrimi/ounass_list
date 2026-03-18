import Foundation

struct FlexibleDecimal: Decodable, Equatable {
    let value: Decimal

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = Decimal(intValue)
            return
        }

        if let doubleValue = try? container.decode(Double.self) {
            value = Decimal(doubleValue)
            return
        }

        if let stringValue = try? container.decode(String.self), let decimal = Decimal(string: stringValue) {
            value = decimal
            return
        }

        throw DecodingError.typeMismatch(
            Decimal.self,
            DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode decimal value.")
        )
    }
}
