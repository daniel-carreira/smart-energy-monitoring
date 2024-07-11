//
//  AlertsView.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import SwiftUI

struct AlertListView: View {
    @State private var alerts: Alerts?
    @State private var alertLoading = true
    
    @State private var equipments: Equipments?
    @State private var equipmentsLoading = true
    
    @State private var showConfig = false
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                Theme.background.edgesIgnoringSafeArea(.top)
                
                if (alertLoading) {
                    ProgressView()
                }
                else {
                    List {
                        ForEach(alerts?.data ?? []) { alert in
                            Section(content: {
                                Text(alert.alert)
                            }, footer: {
                                HStack {
                                    Spacer()
                                    Text(stringDateToPrettyStringDate(alert.timestamp))
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
                    alertLoading = true
                    alerts = try await AlertService.fetchAll(userId: (session.user?.data.id)!, accessToken: session.accessToken!)
                    alertLoading = false
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
        .navigationTitle("Alerts")
    }
}
