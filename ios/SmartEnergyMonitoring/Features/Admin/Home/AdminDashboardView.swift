//
//  AdminDashboardView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 30/12/2022.
//

import SwiftUI
import Charts

struct AdminDashboardView: View {
    @State private var adminStats: AdminStats?
    @State private var adminStatsLoading = true
    
    @State private var adminStatsUsers: AdminStatsUsers?
    @State private var adminStatsUsersLoading = true
    @State private var adminStatsUsersGraphData: [AdminStatsUsersGraphData] = []
    
    @State private var date: Date = Date()
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @State private var storeFilled = false
    
    @EnvironmentObject var session: SessionManager
    
    struct AdminStatsUsersGraphData: Codable, Identifiable {
        var id = UUID()
        var category: String
        var value: Int
    }
    
    func fetchAllStats() -> Void {
        Task {
            do {
                adminStatsLoading = true
                adminStats = try await AdminStatsService.fetch(accessToken: session.accessToken!)
                adminStatsLoading = false
                
                adminStatsUsersLoading = true
                adminStatsUsers = try await AdminStatsService.fetchUsers(accessToken: session.accessToken!)
                adminStatsUsersGraphData = []
                adminStatsUsersGraphData.append(AdminStatsUsersGraphData(category: "Clients", value: adminStatsUsers!.clients))
                adminStatsUsersGraphData.append(AdminStatsUsersGraphData(category: "Admins", value: adminStatsUsers!.admins))
                adminStatsUsersGraphData.append(AdminStatsUsersGraphData(category: "Producers", value: adminStatsUsers!.producers))
                adminStatsUsersLoading = false
                
                storeFilled = true
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
                
                List {
                    Section {
                        DatePicker(
                            "Date",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .onChange(of: date, perform: { _ in
                            fetchAllStats()
                        })
                    }
                    
                    Section("Performance") {
                        if (adminStatsLoading) {
                            ProgressView()
                        }
                        else {
                            Text("Consumptions")
                                .badge(adminStats?.consumptions ?? 0)
                            Text("Observations")
                                .badge(adminStats?.observations ?? 0)
                            Text("Alerts")
                                .badge(adminStats?.alerts ?? 0)
                        }
                    }
                    
                    Section("Users") {
                        if (adminStatsUsersLoading) {
                            ProgressView()
                        }
                        else {
                            Chart(adminStatsUsersGraphData) { // Get the Production values.
                                BarMark(
                                    x: .value("Quantity", $0.value)
                                )
                                .foregroundStyle(by: .value("Class", $0.category))
                            }
                            .padding(.top)
                            Text("Clients")
                                .badge(adminStatsUsers?.clients ?? 0)
                            Text("Admins")
                                .badge(adminStatsUsers?.admins ?? 0)
                            Text("Producers")
                                .badge(adminStatsUsers?.producers ?? 0)
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .onAppear() {
                if (!storeFilled) {
                    fetchAllStats()
                }
            }
            .alert("Data fetch failed", isPresented: $didFail, actions: {
                Button("Ok") {}
            }, message: {
                Text(failMessage)
            })
        }
    }
}
