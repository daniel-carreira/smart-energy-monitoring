//
//  AccountView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 10/12/2022.
//

import SwiftUI

struct AccountView: View {
    
    @State private var notifications: Bool = false
    @State private var birthDate: Date = Date()
    @State private var wakeTime: Date = Date()
    @State private var bedTime: Date = Date()
    @State private var energyPrice: Float = 0.15
    @State private var name: String = ""
    
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                Theme.background.edgesIgnoringSafeArea(.top)
                
                List {
                    
                    Section(content: {
                        
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(name)
                                .foregroundStyle(.secondary)
                        }
                        DatePicker(
                            "Birth Date",
                             selection: $birthDate,
                            in: ...Date.now,
                            displayedComponents: .date
                        )
                        HStack {
                            Text("E-mail")
                            Spacer()
                            Text((session.user?.data.email)!)
                                .foregroundStyle(.secondary)
                        }
                        
                    }, header: {
                        Text("Profile")
                    })
                    
                    Section(content: {
                        
                        HStack {
                            Text("Energy Price")
                            Spacer()
                            Text("\(String(format: "%.3f", energyPrice)) € / kWh")
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(value: $energyPrice, in: 0...0.5)
                            .tint(Theme.primary)
                            .padding()

                        
                    }, header: {
                        Text("Energy")
                    })
                    
                    Section(content: {
                        
                        DatePicker(
                            "Wake Up Time",
                             selection: $wakeTime,
                            in: ...Date.now,
                            displayedComponents: .hourAndMinute
                        )
                        DatePicker(
                            "Bed Time",
                             selection: $bedTime,
                            in: ...Date.now,
                            displayedComponents: .hourAndMinute
                        )
                        
                    }, header: {
                        Text("Routine")
                    })
                    
                    Section(content: {
                        
                        Toggle("E-mail", isOn: $notifications)
                            .tint(Theme.primary)
                        
                    }, header: {
                        Text("Notifications")
                    })
                    
                    Section(content: {
                        
                        Button("Change Password") {
                            //TODO: Open sheet to change password
                        }
                        
                    }, header: {
                        Text("Security")
                    })
                    
                }
                
            }
            .navigationTitle("Account")
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
            .onAppear() {
                let user = session.user?.data
                
                name = user!.name
                notifications = user!.notifications == 1
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                birthDate = dateFormatter.date(from: user!.birthdate)!
                
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                bedTime = dateFormatter.date(from: user!.noActivityStart)!
                wakeTime = dateFormatter.date(from: user!.noActivityEnd)!
                
                energyPrice = Float(user!.energyPrice)!
                
            }
            
        }
        
    }
    
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
