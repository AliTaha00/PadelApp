import Foundation
import FirebaseFirestore

struct User: Codable {
    let id: String
    var email: String
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var gender: Gender
    var age: Int
    var userType: UserType
    var dateJoined: Date
    
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
} 