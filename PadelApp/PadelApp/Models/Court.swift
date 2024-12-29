import Foundation
import FirebaseFirestore

struct Court: Identifiable, Codable {
    let id: String
    let facilityId: String
    let name: String // e.g., "Court 1"
    let type: CourtType
    var isAvailable: Bool = true
    var pricePerHour: Double
    
    enum CourtType: String, Codable {
        case indoor = "Indoor"
        case outdoor = "Outdoor"
        case covered = "Covered Outdoor"
    }
} 