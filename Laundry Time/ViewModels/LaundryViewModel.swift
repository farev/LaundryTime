import Foundation

class LaundryViewModel: ObservableObject {
    @Published var laundryRooms: [LaundryRoom] = []
    private let firebaseService = FirebaseService()
    
    init() {
        firebaseService.initializeDatabase()
        setupFirebaseListeners()
    }
    
    private func setupFirebaseListeners() {
        firebaseService.setupListeners { [weak self] updatedRooms in
            DispatchQueue.main.async {
                print("Updating view model with \(updatedRooms.count) rooms")
                self?.laundryRooms = updatedRooms
            }
        }
    }
    
    func updateMachineStatus(roomId: String, machineId: Int, status: MachineStatus) {
        firebaseService.updateMachineStatus(roomId: roomId, machineId: machineId, status: status)
    }
    
    // Helper function to format time differences
    func getLastUpdateString(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
} 
