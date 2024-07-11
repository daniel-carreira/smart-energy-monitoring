//
//  AlertConfigView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 30/12/2022.
//

import SwiftUI

struct AlertConfigView: View {
    @State private var equipments: Equipments?
    @State private var equipmentsLoading = true
    
    @State private var selected: Equipment?
    @State private var showAlertConfig = false
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    func fetchEquipments() -> Void {
        Task {
            do {
                equipmentsLoading = true
                equipments = try await EquipmentService.fetch(userId: (session.user?.data.id)!, accessToken: session.accessToken!)
                equipmentsLoading = false
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
            ZStack {
                
                Theme.background.edgesIgnoringSafeArea(.top)
                
                VStack {
                    if (equipmentsLoading) {
                        ProgressView()
                    }
                    else {
                        List {
                            Section("Equipments") {
                                ForEach(equipments?.data ?? []) { equipment in
                                    Button(action: {
                                        selected = equipment
                                        showAlertConfig = true
                                    }, label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(equipment.name)
                                                    .foregroundColor(Theme.text)
                                                Text("\(equipment.divisionName)")
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            HStack {
                                                Text("\(equipment.notifyWhenPassed == nil ? "" : String(equipment.notifyWhenPassed!) + " minute(s)")")
                                                    .foregroundColor(.gray)
                                                Symbols.arrow
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Alerts")
        .onAppear() {
            fetchEquipments()
        }
        .alert("Data fetch failed", isPresented: $didFail, actions: {
            Button("Ok") {}
        }, message: {
            Text(failMessage)
        })
        .sheet(isPresented: $showAlertConfig, content: {
            AlertConfigSheetView(selected: $selected, showAlertConfig: $showAlertConfig)
        })
    }
}
