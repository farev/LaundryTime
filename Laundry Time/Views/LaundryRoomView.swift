import SwiftUI

struct LaundryRoomView: View {
    let room: LaundryRoom
    @ObservedObject var viewModel: LaundryViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Last update time
                Text("Last updated: \(viewModel.getLastUpdateString(date: room.lastUpdated))")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
                Text("Washers")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(room.machines.filter { $0.type == .washer }) { machine in
                        MachineCell(machine: machine, roomId: room.id ?? "", viewModel: viewModel) {
                            showStatusSheet(for: machine)
                        }
                    }
                }
                
                Text("Dryers")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(room.machines.filter { $0.type == .dryer }) { machine in
                        MachineCell(machine: machine, roomId: room.id ?? "", viewModel: viewModel) {
                            showStatusSheet(for: machine)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(room.name)
    }
    
    func showStatusSheet(for machine: Machine) {
        let newStatus: MachineStatus = machine.status == .available ? .occupied : .available
        if let roomId = room.id {
            viewModel.updateMachineStatus(roomId: roomId, machineId: machine.id, status: newStatus)
        }
    }
}

struct MachineCell: View {
    let machine: Machine
    let roomId: String
    @ObservedObject var viewModel: LaundryViewModel
    let action: () -> Void
    
    init(machine: Machine, roomId: String, viewModel: LaundryViewModel, action: @escaping () -> Void) {
        self.machine = machine
        self.roomId = roomId
        self.viewModel = viewModel
        self.action = action
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Menu {
                    if machine.status == .outOfOrder {
                        Button("Mark as Working") {
                            viewModel.updateMachineStatus(roomId: roomId, machineId: machine.id, status: .available)
                        }
                    } else {
                        Button("Mark as Out of Order") {
                            viewModel.updateMachineStatus(roomId: roomId, machineId: machine.id, status: .outOfOrder)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing, -8)
            
            Button(action: action) {
                VStack {
                    Image(systemName: machine.type == .washer ? "washer" : "dryer")
                        .font(.system(size: 30))
                        .foregroundColor(machine.status == .outOfOrder ? .gray : .primary)
                    Text("#\(machine.id)")
                        .font(.caption)
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(statusColor)
                    
                    Text(viewModel.getLastUpdateString(date: machine.lastStatusUpdate))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .disabled(machine.status == .outOfOrder)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(machine.status == .outOfOrder ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    var statusText: String {
        switch machine.status {
        case .available: return "Available"
        case .occupied: return "Occupied"
        case .outOfOrder: return "Out of Order"
        }
    }
    
    var statusColor: Color {
        switch machine.status {
        case .available: return .green
        case .occupied: return .red
        case .outOfOrder: return .orange
        }
    }
} 

#Preview {
    NavigationView {
        let viewModel = LaundryViewModel()
        let sampleRoom = LaundryRoom(
            id: "preview",
            name: "Preview Room",
            machines: [
                Machine(id: 1, type: .washer, status: .available, lastStatusUpdate: Date()),
                Machine(id: 2, type: .washer, status: .occupied, lastStatusUpdate: Date()),
                Machine(id: 3, type: .dryer, status: .outOfOrder, lastStatusUpdate: Date())
            ],
            lastUpdated: Date()
        )
        return LaundryRoomView(room: sampleRoom, viewModel: viewModel)
    }
} 
