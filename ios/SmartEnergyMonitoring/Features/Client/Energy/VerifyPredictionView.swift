//
//  VerifyPredictionView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 30/12/2022.
//

import SwiftUI

struct VerifyPredictionView: View {
    @Binding var observation: Observation?
    @Binding var equipments: Equipments?
    
    @State private var divisions: [DivisionShort] = []
    
    @State private var requestLoading = false
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    @Environment(\.dismiss) var dismiss
    
    func submitManualLabel() -> Void {
        Task {
            do {
                requestLoading = true
                var devices: [String: Double] = [:]
                observation?.observation.equipments.forEach { device in
                    devices[device.id.description] = Double(device.consumption)!
                }
                let timestamp = observation!.consumption.timestamp
                let body = TrainingExamples(start: timestamp, end: timestamp, equipments: devices)
                let decoded = try JSONEncoder().encode(body)
                
                try await TrainingExamplesService.post(userId: (session.user?.data.id)!, accessToken: session.accessToken!, parameters: decoded)
                requestLoading = false
                dismiss()
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                failMessage = errorMessage
                didFail = true
            }
        }
    }
    
    init(observation: Binding<Observation?>, equipments: Binding<Equipments?>) {
        self._observation = observation
        self._equipments = equipments
        var divSet: Set<DivisionShort> = []
        self.equipments?.data.forEach { equipment in
            let division = DivisionShort(id: equipment.division, name: equipment.divisionName)
            divSet.insert(division)
        }
        divisions = Array(divSet)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Theme.background.edgesIgnoringSafeArea(.top)
                
                VStack {
                    List {
                        Section {
                            HStack {
                                Text("Date")
                                Spacer()
                                Text(unixTimestampToFormatedString(observation?.consumption.timestamp))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Section("Equipments") {
                            ForEach(observation?.observation.equipments ?? []) { equipment in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(equipment.name)
                                        Text("\(equipment.divisionName)")
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("\(equipment.consumption) W")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        Section {
                            Button(action: {
                                submitManualLabel()
                            }, label: {
                                HStack {
                                    Symbols.check
                                    Text("Correct")
                                }
                            })
                            Button(role: .destructive, action: {
                                dismiss()
                            }, label: {
                                HStack {
                                    Symbols.xmark
                                    Text("Wrong")
                                }
                            })
                        }
                    }
                }
                
            }
        }
        .alert("Something went wrong!", isPresented: $didFail, actions: {
            Button("Ok") {}
        }, message: {
            Text(failMessage)
        })
        .navigationTitle("Verify Prediction")
        .overlay(loadingOverlay)
    }
    
    @ViewBuilder private var loadingOverlay: some View {
        if requestLoading {
            ZStack {
                Color(white: 0, opacity: 0.75)
                ProgressView().tint(.white)
            }
        }
    }
}
