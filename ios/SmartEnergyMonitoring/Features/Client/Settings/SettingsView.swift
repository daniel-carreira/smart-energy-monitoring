//
//  SettingsView.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import SwiftUI

struct SettingsView: View {
    @State private var notifications: Bool = false
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    func toggleNotifications(value: Int) -> Void {
        Task {
            do {
                let data = ["notifications": value]
                let parameters = try? JSONEncoder().encode(data)
                try await UserService.patchNotifications(userId: session.user!.data.id, accessToken: session.accessToken!, parameters: parameters!)
                session.user?.data.notifications = notifications ? 1 : 0
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                failMessage = errorMessage
                didFail = true
            }
        }
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                Theme.background.edgesIgnoringSafeArea(.top)
                
                List {
                    
                    NavigationLink(destination: ProfileView(), label: {
                        HStack {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                    })
                    
                    NavigationLink(destination: AffiliateListView(), label: {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Affiliates")
                        }
                    })
                    
                    NavigationLink(destination: AlertConfigView(), label: {
                        HStack {
                            Image(systemName: "paperplane")
                            Text("Alerts")
                        }
                    })
                    
                    Toggle(isOn: $notifications, label: {
                        HStack {
                            Image(systemName: "bell")
                            Text("Notifications")
                        }
                    })
                        .onChange(of: notifications, perform: { newValue in
                            toggleNotifications(value: newValue ? 1 : 0)
                        })
                        .tint(Theme.primary)
                    
                    Section("Household") {
                        
                        NavigationLink(destination: DivisionListView(), label: {
                            HStack {
                                Image(systemName: "square.split.bottomrightquarter")
                                Text("Divisions")
                            }
                        })
                        
                        NavigationLink(destination: EquipmentListView(), label: {
                            HStack {
                                Image(systemName: "powerplug")
                                Text("Devices")
                            }
                        })
                        
                    }
                    
                    Section("Security") {
                        
                        Button(action: {
                            //TODO: Open sheet to change password
                        }, label: {
                            HStack {
                                Image(systemName: "key.fill")
                                Text("Change Password")
                            }
                            
                        })
                        
                    }
                    
                }
                
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        session.signOut()
                    }
                    label: {
                        Symbols.logout
                        Text("Logout")
                    }
                }
            }
            .alert("Update failed", isPresented: $didFail, actions: {
                Button("Ok") { }
            }, message: {
                Text(failMessage)
            })
            .onAppear() {
                let user = session.user?.data
                notifications = user!.notifications == 1
            }
            
        }
        
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
