//
//  MainAdminView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 30/12/2022.
//

import SwiftUI

struct MainAdminView: View {
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        
        TabView {
            
            AdminDashboardView()
                .tabItem {
                    Symbols.home
                    Text("Dashboard")
                }
                .environmentObject(session)
            
            AdminSettingsView()
                .tabItem {
                    Symbols.settings
                    Text("Settings")
                }
                .environmentObject(session)
            
        }
    }
}
