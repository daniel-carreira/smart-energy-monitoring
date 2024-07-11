//
//  EquipmentCreateView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 05/01/2023.
//

import SwiftUI

struct EquipmentCreateView: View {
    var onCompletion: () -> Void
    
    @State var divisions: Divisions?
    @State var equipmentTypes: EquipmentTypes?
    
    @State var selectedDivision = 0
    @State var selectedActivity = "Yes"
    @State var selectedType = 9
    
    @State private var name = ""
    @State private var consumption: Float?
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    @Environment(\.dismiss) var dismiss
    
    func create() {
        Task {
            do {
                let data = PostEquipment(name: name, activity: selectedActivity, consumption: Int(consumption ?? 0), equipmentTypeId: selectedType, divisionId: selectedDivision, standby: 0)
                let encode = try JSONEncoder().encode(data)
                try await EquipmentService.create(userId: session.user!.data.id, accessToken: session.accessToken!, parameters: encode)
                onCompletion()
                dismiss()
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                failMessage = errorMessage
                didFail = true
            }
        }
    }
    
    func fetchEquipmentTypes() {
        Task {
            do {
                equipmentTypes = try await EquipmentTypeService.fetchAll(accessToken: session.accessToken!)
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                failMessage = errorMessage
                didFail = true
            }
            catch APIHelper.APIError.decodingError {
                failMessage = "Decoding Error"
                didFail = true
            }
        }
    }
    
    func fetchDivisions() {
        Task {
            do {
                divisions = try await DivisionService.fetch(userId: session.user!.data.id, accessToken: session.accessToken!)
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                failMessage = errorMessage
                didFail = true
            }
            catch APIHelper.APIError.decodingError {
                failMessage = "Decoding Error"
                didFail = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    TextField("Device name", text: $name)
                    Picker("Device type", selection: $selectedType) {
                        ForEach(equipmentTypes?.data ?? []) { equipmentType in
                            Text(equipmentType.name).tag(equipmentType.id)
                        }
                    }
                    Picker("Division", selection: $selectedDivision) {
                        ForEach(divisions?.data ?? []) { division in
                            Text(division.name).tag(division.id)
                        }
                    }
                    TextField("Consumption (Watts)", value: $consumption, format: .number)
                    
                    Picker("Manual Activation", selection: $selectedActivity) {
                        Text("Yes").tag("Yes")
                        Text("No").tag("No")
                    }
                }
            }
            .navigationBarTitle("Create", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        create()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear() {
                fetchDivisions()
                fetchEquipmentTypes()
            }
            .alert("Data fetch failed", isPresented: $didFail, actions: {
                Button("Ok") {}
            }, message: {
                Text(failMessage)
            })
            .alert("Create failed", isPresented: $didFail, actions: {
                Button("Ok") {}
            }, message: {
                Text(failMessage)
            })
        }
    }
}
