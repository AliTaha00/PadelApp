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
    var numericRating: Double
    
    // New fields
    var playingHand: PlayingHand
    var preferredPosition: CourtPosition
    var padelExperience: ExperienceLevel
    var racketSportsExperience: ExperienceLevel
    var playingFrequency: PlayingFrequency
    
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
    
    enum PlayingHand: String, Codable {
        case right = "Right"
        case left = "Left"
    }
    
    enum CourtPosition: String, Codable {
        case backhand = "Backhand"
        case forehand = "Forehand"
        case both = "Both"
    }
    
    enum ExperienceLevel: String, Codable, Identifiable {
        case none = "No Experience"
        case lessThanYear = "Less than 1 year"
        case oneToTwo = "1-2 years"
        case twoToFive = "2-5 years"
        case moreThanFive = "More than 5 years"
        
        var id: String { self.rawValue }
        
        var ratingContribution: Double {
            switch self {
            case .none: return 0.5
            case .lessThanYear: return 2.0
            case .oneToTwo: return 4.0
            case .twoToFive: return 7.0
            case .moreThanFive: return 10.0
            }
        }
    }
    
    enum PlayingFrequency: String, Codable, Identifiable {
        case rarely = "Less than once a month"
        case occasionally = "1-2 times a month"
        case regularly = "1-2 times a week"
        case frequently = "3+ times a week"
        
        var id: String { self.rawValue }
        
        var ratingContribution: Double {
            switch self {
            case .rarely: return 0.5
            case .occasionally: return 2.0
            case .regularly: return 3.5
            case .frequently: return 5.0
            }
        }
    }
} 