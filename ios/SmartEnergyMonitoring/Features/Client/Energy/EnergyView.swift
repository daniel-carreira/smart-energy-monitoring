//
//  EnergyView.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import SwiftUI

struct EnergyView: View {
    @State private var equipmentsLoading = true
    @State private var equipments: Equipments?
    @State private var observationLoading = true
    @State private var latestObservation: Observation?
    
    @State private var todoList: [Equipment] = []
    @State private var doneList: [Equipment] = []
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @State private var showHelp = false
    
    @EnvironmentObject var session: SessionManager
    
    struct NameValue: Identifiable {
        let id = UUID()
        var name: String
        var value: String
        var items: [NameValue] = []
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                Theme.background.edgesIgnoringSafeArea(.top)
                
                List {
                    if (showHelp) {
                        Text("In this section, you can deliver tasks to help us trace better your electrical profile, thus improving the overall system performance. We recommend you to perform the tasks without checkmark.")
                    }
                    if (latestObservation != nil) {
                        Section {
                            NavigationLink(destination: VerifyPredictionView(observation: $latestObservation, equipments: $equipments)) {
                                HStack {
                                    Symbols.circle
                                        .foregroundStyle(Theme.primary)
                                    Text("Verify Prediction")
                                        .foregroundColor(Theme.text)
                                    Spacer()
                                    if (observationLoading) {
                                        ProgressView()
                                    }
                                }
                            }
                        }
                    }
                    
                    Section("Devices") {
                        ForEach(todoList) { equipment in
                            NavigationLink(destination: DataAcquisitionView(equipment: equipment)) {
                                HStack {
                                    Symbols.circle
                                        .foregroundStyle(Theme.primary)
                                    Text(equipment.name)
                                        .foregroundColor(Theme.text)
                                    Spacer()
                                    Text("\(equipment.examples) reads")
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        ForEach(doneList) { equipment in
                            NavigationLink(destination: DataAcquisitionView(equipment: equipment)) {
                                HStack {
                                    Symbols.checkmark
                                        .foregroundStyle(Theme.primary)
                                    Text(equipment.name)
                                        .foregroundColor(Theme.text)
                                    Spacer()
                                    Text("\(equipment.examples) reads")
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    
                }
            }
            .navigationTitle("Performance")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showHelp = true
                    } label: {
                        HStack {
                            Symbols.help
                            Text("Help")
                        }
                    }

                }
            }
            .onAppear() {
                showHelp = false
                Task {
                    do {
                        equipmentsLoading = true
                        equipments = try await EquipmentService.fetch(userId: (session.user?.data.id)!, accessToken: session.accessToken!)
                        equipmentsLoading = false
                        
                        todoList = (equipments?.data.filter{ $0.examples == 0 })!
                        doneList = (equipments?.data.filter{ $0.examples > 0 })!
                        
                        observationLoading = true
                        latestObservation = nil
                        latestObservation = try await ObservationService.fetchLast(userId: (session.user?.data.id)!, accessToken: session.accessToken!)
                        observationLoading = false
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
        }
    }
}
