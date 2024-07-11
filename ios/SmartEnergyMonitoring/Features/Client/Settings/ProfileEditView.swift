//
//  ProfileEditView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 05/01/2023.
//

import SwiftUI

struct ProfileEditView: View {
    @State private var requestLoading = false
    
    @State private var notifications: Bool = false
    @State private var birthDate: Date = Date()
    @State private var wakeTime: Date = Date()
    @State private var bedTime: Date = Date()
    @State private var energyPrice: Float = 0.15
    @State private var name: String = ""
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    @Environment(\.dismiss) var dismiss
    
    func update() -> Void {
        Task {
            do {
                requestLoading = true
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let birthDateString = dateFormatter.string(from: birthDate)
                //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                //let wake = dateFormatter.string(from: wakeTime)
                //let bed = dateFormatter.string(from: bedTime)
                
                let putUser = PutUser(name: name, birthdate: birthDateString, noActivityStart: nil, noActivityEnd: nil, energyPrice: energyPrice)
                let encode = try JSONEncoder().encode(putUser)
                
                try await UserService.update(userId: session.user!.data.id, accessToken: session.accessToken!, parameters: encode)
                try await session.refreshUser()
                
                requestLoading = false
                
                dismiss()
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                requestLoading = false
                failMessage = errorMessage
                didFail = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    
                    Section {
                        
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(name)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("E-mail")
                            Spacer()
                            Text((session.user?.data.email)!)
                                .foregroundStyle(.secondary)
                        }
                        DatePicker(
                            "Birth Date",
                            selection: $birthDate,
                            in: ...Date.now,
                            displayedComponents: .date
                        )
                    }
                    
                    Section("Energy") {
                        VStack {
                            HStack {
                                Text("Price")
                                Spacer()
                                Text("\(String(format: "%.3f", energyPrice)) € / kWh")
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: $energyPrice, in: 0...0.5)
                                .tint(Theme.primary)
                                .padding()
                        }
                    }
                    
                    Section("Routine") {
                        
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
                        
                    }
                }
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        update()
                    }
                    .fontWeight(.bold)
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
                bedTime = dateFormatter.date(from: user!.noActivityEnd)!
                wakeTime = dateFormatter.date(from: user!.noActivityStart)!
                
                energyPrice = Float(user!.energyPrice)!
                
            }
            .alert("Update failed", isPresented: $didFail, actions: {
                Button("Ok") {}
            }, message: {
                Text(failMessage)
            })
            .overlay(loadingOverlay)
        }
    }
    
    @ViewBuilder private var loadingOverlay: some View {
        if requestLoading {
            ZStack {
                Color(white: 0, opacity: 0.75)
                ProgressView().tint(.white)
            }
        }
    }
}
