import Foundation
import FirebaseFirestore

struct User: Codable {
    var id: String?
    var email: String
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var gender: Gender
    var age: Int
    var userType: UserType
    var dateJoined: Date
    var skillLevel: SkillLevel
    var numericRating: Double
    
    enum Gender: String, Codable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
    
    enum UserType: String, Codable {
        case player
        case facilityOwner
        case admin
    }
    
    enum SkillLevel: String, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
        
        var baseRating: Double {
            switch self {
            case .beginner: return 1.0
            case .intermediate: return 2.0
            case .advanced: return 3.0
            case .expert: return 4.0
            }
        }
    }
} 