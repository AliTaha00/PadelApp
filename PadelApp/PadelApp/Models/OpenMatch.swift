import SwiftUI
import FirebaseFirestore


struct OpenMatch: Codable, Identifiable {
    var id: String?
    var creatorId: String
    var facilityId: String
    var facilityName: String
    var date: Date
    var timeSlot: Date
    var duration: Int
    var matchType: String
    var genderPreference: String
    var status: String
    var players: [String]
    var createdAt: Date
} 