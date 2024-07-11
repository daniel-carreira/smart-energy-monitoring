//
//  ProfileView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 10/12/2022.
//

import SwiftUI

struct ProfileView: View {
    @State private var wakeTime: String = ""
    @State private var bedTime: String = ""
    @State private var energyPrice: Float = 0.15
    
    @State private var showEdit = false
    
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        
        ZStack {
            
            Theme.background.edgesIgnoringSafeArea(.top)
            
            List {
                
                Section {
                    
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(session.user!.data.name)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("E-mail")
                        Spacer()
                        Text(session.user!.data.email)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Birth Date")
                        Spacer()
                        Text((session.user?.data.birthdate)!)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Energy") {
                    HStack {
                        Text("Price")
                        Spacer()
                        Text("\(String(format: "%.3f", Float(session.user!.data.energyPrice)!)) € / kWh")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Routine") {
                    
                    HStack {
                        Text("Wake Up Time")
                        Spacer()
                        Text(wakeTime)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Bed Time")
                        Spacer()
                        Text(bedTime)
                            .foregroundStyle(.secondary)
                    }
                    
                }
            }
            
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showEdit = true
                }, label: {
                    HStack {
                        Symbols.edit
                        Text("Edit")
                    }
                })
            }
        }
        .sheet(isPresented: $showEdit, content: {
            ProfileEditView()
        })
        .onAppear() {
            let user = session.user?.data
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let bedTimeDate = dateFormatter.date(from: user!.noActivityStart)!
            let wakeTimeDate = dateFormatter.date(from: user!.noActivityEnd)!
            
            dateFormatter.dateFormat = "HH:mm"
            
            bedTime = dateFormatter.string(from: bedTimeDate)
            wakeTime = dateFormatter.string(from: wakeTimeDate)
            
            energyPrice = Float(user!.energyPrice)!
            
        }
    }
}
