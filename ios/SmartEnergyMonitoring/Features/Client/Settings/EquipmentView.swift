//
//  EquipmentView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 11/12/2022.
//

import SwiftUI

struct EquipmentView: View {
    @State var equipment: Equipment
    
    @State private var showDelete = false
    @State private var showEdit = false
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @State private var toggleState = false
    
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var mqtt: MQTTManager
    
    @Environment(\.dismiss) var dismiss
    
    func delete() {
        Task {
            do {
                try await EquipmentService.delete(userId: session.user!.data.id, accessToken: session.accessToken!, equipmentId: equipment.id)
                dismiss()
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                failMessage = errorMessage
                didFail = true
            }
        }
    }
    
    func updateSocketStatus(value: Int) -> Void {
        Task {
            do {
                let decoded = try JSONEncoder().encode(["socket": value.description])
                try await EquipmentService.patchSocket(userId: (session.user?.data.id)!, accessToken: session.accessToken!, equipmentId: equipment.id, parameters: decoded)
                equipment.socket = value
                if (value == -1) {
                    toggleState = false
                    return
                }
                mqtt.publish(topic: "\(session.user!.data.id)/smart-socket", with: "\(value)")
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                failMessage = errorMessage
                didFail = true
            }
        }
    }
    
    var body: some View {
        
        ZStack {
            
            Theme.background.edgesIgnoringSafeArea(.top)
            
            List {
                Section {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(equipment.name)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(equipment.typeName)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Division")
                        Spacer()
                        Text(equipment.divisionName)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Consumption")
                        Spacer()
                        Text("\(equipment.consumption) W")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Manual Activation")
                        Spacer()
                        Text(equipment.activity)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Smart Socket") {
                    if (equipment.socket != -1) {
                        Toggle("State", isOn: $toggleState)
                            .onChange(of: toggleState) { value in
                                updateSocketStatus(value: value ? 1 : 0)
                            }
                            .tint(.accentColor)
                    }
                    Button(action: {
                        updateSocketStatus(value: equipment.socket == -1 ? 0 : -1)
                    }, label: {
                        Text(equipment.socket == -1 ? "Activate" : "Deactivate")
                    })
                }
                
                
            }
            
        }
        .navigationTitle(equipment.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showEdit = true
                    }
                    label: {
                        Symbols.edit
                        Text("Edit")
                    }
                    Button {
                        showDelete = true
                    }
                    label: {
                        Symbols.delete
                        Text("Delete")
                    }
                } label: {
                    HStack {
                        Symbols.options
                        Text("Actions")
                    }
                }
            }
        }
        .onAppear {
            toggleState = equipment.socket == 1
        }
        .sheet(isPresented: $showEdit, content: {
            EquipmentEditView(equipment: $equipment)
        })
        .alert("Are you sure?", isPresented: $showDelete, actions: {
            Button("Delete", role: .destructive) {
                delete()
            }
        }, message: {
            Text("Delete \(equipment.name) from your devices")
        })
        
    }
}
