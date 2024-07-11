//
//  ObservationsView.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import SwiftUI

struct ObservationListView: View {
    
    @State private var observations: Observations?
    @State private var observationsLoading = true
    
    @State private var activeDivisions: Set<DivisionShort> = []
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @State private var selected: Observation?
    @State private var showObservation = false
    
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                Theme.background.edgesIgnoringSafeArea(.top)
                
                if (observationsLoading) {
                    
                    ProgressView()
                    
                }
                else {
                    
                    List {
                        ForEach(observations ?? [], id: \.consumption.id) { observation in
                            Section(content: {
                                Button(action: {
                                    selected = observation
                                    selected?.observation.equipments.filter { $0.consumption != "0.00" }.forEach { equipment in
                                        let division = DivisionShort(id: equipment.division, name: equipment.divisionName)
                                        activeDivisions.insert(division)
                                    }
                                    showObservation = true
                                }, label: {
                                    HStack {
                                        Text("Devices ON")	
                                            .foregroundColor(Theme.text)
                                        Spacer()
                                        Text("\(observation.observation.equipments.filter{ $0.consumption != "0.00" }.count)")
                                            .foregroundStyle(.gray)
                                        Symbols.arrow
                                            .foregroundStyle(.gray)
                                    }
                                })
                            }, footer: {
                                HStack {
                                    Spacer()
                                    Text(unixTimestampToFormatedString(observation.consumption.timestamp))
                                }
                            })
                        }
                    }
                    
                }
            }
        }
        .onAppear() {
            Task {
                do {
                    observationsLoading = true
                    observations = try await ObservationService.fetchAll(userId: (session.user?.data.id)!, accessToken: session.accessToken!)
                    observationsLoading = false
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
        .alert("Data fetch failed", isPresented: $didFail, actions: {
            Button("Ok") {}
        }, message: {
            Text(failMessage)
        })
        .navigationTitle("Energy Activity List")
        .sheet(isPresented: $showObservation) {
            ObservationView(observation: $selected, divisions: $activeDivisions)
        }
    }
}
