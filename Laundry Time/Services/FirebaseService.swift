import Firebase
import FirebaseFirestore

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    private let laundryRoomsCollection = "laundryRooms"
    
    func setupListeners(completion: @escaping ([LaundryRoom]) -> Void) {
        print("Setting up Firebase listeners...")
        db.collection(laundryRoomsCollection)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error listening for updates: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents in snapshot")
                    return
                }
                
                print("Received update with \(documents.count) rooms")
                let laundryRooms = documents.compactMap { document -> LaundryRoom? in
                    if let room = try? document.data(as: LaundryRoom.self) {
                        print("Successfully decoded room: \(room.name)")
                        return room
                    } else {
                        print("Failed to decode room from document: \(document.documentID)")
                        return nil
                    }
                }
                completion(laundryRooms)
            }
    }
    
    func updateMachineStatus(roomId: String, machineId: Int, status: MachineStatus) {
        print("Updating machine \(machineId) in room \(roomId) to status: \(status)")
        let roomRef = db.collection(laundryRoomsCollection).document(roomId)
        
        roomRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard var room = try? document?.data(as: LaundryRoom.self) else {
                print("Failed to decode room data")
                return
            }
            
            if let index = room.machines.firstIndex(where: { $0.id == machineId }) {
                room.machines[index].status = status
                room.machines[index].lastStatusUpdate = Date()
                room.lastUpdated = Date()
                
                do {
                    try roomRef.setData(from: room)
                    print("Successfully updated machine status in Firestore")
                } catch {
                    print("Error updating document: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func initializeDatabase() {
        // First check if data already exists
        db.collection(laundryRoomsCollection).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error checking database: \(error)")
                return
            }
            
            // Only initialize if there are NO documents at all
            if let snapshot = snapshot, snapshot.documents.isEmpty {
                print("Database is empty, initializing with default data...")
                self?.createInitialData()
            } else {
                print("Database already contains data, skipping initialization")
            }
        }
    }
    
    private func createInitialData() {
        let laundryRoomData = [
            ("8th Street West", 22, 26),
            ("Center Street North", 12, 12),
            ("Crecine", 11, 11),
            ("Fitten", 20, 26),
            ("GLC", 15, 14),
            ("Glenn Hall - 3rd Fl", 4, 6),
            ("Glenn Hall - 2nd Fl", 4, 6),
            ("Glenn Hall - 1st Fl", 4, 6),
            ("Glenn Hall - Bsmt", 4, 6),
            ("Glenn Hall - Attic", 1, 1),
            ("Hopkins", 16, 20),
            ("Maulding", 12, 16),
            ("NAA East", 20, 22),
            ("NAA North", 21, 24),
            ("NAA South", 18, 20),
            ("Nelson Shell", 23, 24),
            ("Towers - 1st Fl", 4, 6),
            ("Towers - 2nd Fl", 4, 6),
            ("Towers - Top Fl", 1, 1),
            ("Woodruff South", 12, 12)
        ]
        
        for (name, numWashers, numDryers) in laundryRoomData {
            let room = LaundryRoom(
                name: name,
                machines: generateMachines(washers: numWashers, dryers: numDryers),
                lastUpdated: Date()
            )
            
            do {
                try db.collection(laundryRoomsCollection)
                    .document()
                    .setData(from: room)
                print("Successfully initialized room: \(name)")
            } catch {
                print("Error initializing room \(name): \(error)")
            }
        }
    }
    
    private func generateMachines(washers: Int, dryers: Int) -> [Machine] {
        var machines: [Machine] = []
        
        // Add washers
        for i in 1...washers {
            machines.append(Machine(
                id: i,
                type: .washer,
                status: .available,
                lastStatusUpdate: Date()
            ))
        }
        
        // Add dryers
        for i in (washers + 1)...(washers + dryers) {
            machines.append(Machine(
                id: i,
                type: .dryer,
                status: .available,
                lastStatusUpdate: Date()
            ))
        }
        
        return machines
    }
} 
