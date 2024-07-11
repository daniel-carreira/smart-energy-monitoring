//
//  AdminSettingsView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 30/12/2022.
//

import SwiftUI

struct AdminSettingsView: View {
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.edgesIgnoringSafeArea(.top)
                
                List {
                    NavigationLink("Profile", destination: AdminProfileView())
                    
                    Section("Resources") {
                        NavigationLink("Users", destination: AdminUserListView())
                        NavigationLink("Equipment Types", destination: AdminEquipmentTypeListView())
                    }
                    
                    Section("Security") {
                        Button("Change Password") {
                            //TODO: Open sheet to change password
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // TODO: action
                        session.signOut()
                    }
                    label: {
                        Symbols.logout
                        Text("Logout")
                    }
                }
            }
        }
    }
}
