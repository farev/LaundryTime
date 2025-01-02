import Foundation
import FirebaseFirestore

struct LaundryRoom: Identifiable, Codable {
    @DocumentID var id: String?  // Changed to String for Firebase compatibility
    let name: String
    var machines: [Machine]
    var lastUpdated: Date
    
    // Firebase requires a default initializer when using Codable
    init(id: String? = nil, name: String, machines: [Machine], lastUpdated: Date = Date()) {
        self.id = id
        self.name = name
        self.machines = machines
        self.lastUpdated = lastUpdated
    }
}

struct Machine: Identifiable, Codable {
    let id: Int
    let type: MachineType
    var status: MachineStatus
    var lastStatusUpdate: Date
}

enum MachineType: String, Codable {
    case washer
    case dryer
}

enum MachineStatus: String, Codable {
    case available
    case occupied
    case outOfOrder
} 
