import Foundation
import FirebaseFirestore

struct Booking: Identifiable, Codable {
    let id: String
    let facilityId: String
    let courtId: String
    let userId: String
    let date: Date
    let startTime: Int  // 24-hour format (e.g., 14 for 2:00 PM)
    let duration: Int   // in minutes (e.g., 90 for 1.5 hours)
    let status: BookingStatus
    let totalPrice: Double
    
    enum BookingStatus: String, Codable {
        case pending
        case confirmed
        case completed
        case cancelled
    }
} 