//
//  MainView.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 05/10/2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: SessionManager
    @StateObject var mqtt = MQTTManager.shared()
    
    var body: some View {
        
        TabView {
            
            DashboardView()
                .tabItem {
                    Symbols.home
                    Text("Dashboard")
                }
                .environmentObject(session)
                .environmentObject(mqtt)
            
            
            EnergyView()
                .tabItem {
                    Symbols.bolt
                    Text("Performance")
                }
                .environmentObject(session)
                .environmentObject(mqtt)
            
            
            ARView()
                .tabItem {
                    Symbols.ar
                    Text("AR")
                }
                .environmentObject(session)
            
            
            SettingsView()
                .tabItem {
                    Symbols.settings
                    Text("Settings")
                }
                .environmentObject(session)
                .environmentObject(mqtt)
            
        }
        .onAppear() {
            mqtt.initializeMQTT(userID: (session.user?.data.id)!)
            mqtt.connect()
        }
        
    }
}
