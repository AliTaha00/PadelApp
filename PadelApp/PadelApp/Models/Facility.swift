import Foundation
import FirebaseFirestore

struct Facility: Identifiable, Codable {
    let id: String
    let name: String
    let address: String
    let phoneNumber: String
    let email: String
    let numberOfCourts: Int
    let openingHour: Int // 24-hour format
    let closingHour: Int // 24-hour format
    var imageURL: String?
    
    // Additional properties we might need
    var isActive: Bool = true
    var pricePerHour: Double
} 