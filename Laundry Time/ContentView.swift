//
//  ContentView.swift
//  Laundry Time
//
//  Created by Fabian  Arevalo on 1/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LaundryViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(viewModel.laundryRooms) { room in
                        NavigationLink(destination: LaundryRoomView(room: room, viewModel: viewModel)) {
                            LaundryRoomCard(room: room)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Laundry Time")
        }
    }
}

struct LaundryRoomCard: View {
    let room: LaundryRoom
    
    var body: some View {
        VStack {
            Image(systemName: "washer")
                .font(.system(size: 40))
            Text(room.name)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
