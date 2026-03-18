import Foundation

struct ColorOptionResponse: Decodable {
    let styleColorId: String?
    let url: String?
    let label: String?
    let thumbnail: String?
    let hex: String?
    let isInStock: Bool?
}
