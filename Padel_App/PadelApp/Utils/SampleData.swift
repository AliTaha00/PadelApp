import Foundation
import FirebaseFirestore

class SampleDataManager {
    static func addSampleFacilities() {
        print("Starting to add sample facilities...")
        
        // First verify Firebase connection
        let db = Firestore.firestore()
        
        // Test write to see if Firebase is connected
        db.collection("test").document("test").setData([
            "test": "test"
        ]) { err in
            if let err = err {
                print("Error writing test document: \(err)")
            } else {
                print("Test document successfully written")
                
                // Now add facilities
                let facilities = [
                    [
                        "id": "facility1",
                        "name": "Downtown Padel Club",
                        "address": "123 Main St, New York, NY",
                        "phoneNumber": "(555) 123-4567",
                        "email": "info@downtownpadel.com",
                        "numberOfCourts": 4,
                        "openingHour": 7,
                        "closingHour": 22,
                        "isActive": true,
                        "pricePerHour": 40.0
                    ] as [String : Any]
                ]
                
                // Add facilities one by one
                for facility in facilities {
                    print("Attempting to add facility: \(facility["name"] ?? "")")
                    
                    db.collection("facilities").document(facility["id"] as! String).setData(facility) { err in
                        if let err = err {
                            print("Error adding facility: \(err)")
                        } else {
                            print("Facility successfully added!")
                            
                            // Add courts for this facility
                            for i in 1...(facility["numberOfCourts"] as! Int) {
                                let court = [
                                    "id": "\(facility["id"]!)_court\(i)",
                                    "facilityId": facility["id"]!,
                                    "name": "Court \(i)",
                                    "type": i % 2 == 0 ? "Indoor" : "Outdoor",
                                    "isAvailable": true,
                                    "pricePerHour": facility["pricePerHour"]!
                                ] as [String : Any]
                                
                                db.collection("courts").document(court["id"] as! String).setData(court) { err in
                                    if let err = err {
                                        print("Error adding court: \(err)")
                                    } else {
                                        print("Court successfully added!")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
} 