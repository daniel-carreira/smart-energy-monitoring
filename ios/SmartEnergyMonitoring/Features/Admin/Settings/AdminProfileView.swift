//
//  AdminProfileView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 30/12/2022.
//

import SwiftUI

struct AdminProfileView: View {
    @State private var birthDate: Date = Date()
    @State private var name: String = ""
    
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        
        ZStack {
            
            Theme.background.edgesIgnoringSafeArea(.top)
            
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
                
            }
            
        }
        .navigationTitle("Profile")
        .onAppear() {
            let user = session.user?.data
            name = user!.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            birthDate = dateFormatter.date(from: user!.birthdate)!
        }
        
    }
}
