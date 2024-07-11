//
//  AdminUserView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 31/12/2022.
//

import SwiftUI

struct AdminUserView: View {
    @Binding var user: UserClass?
    @State var locked: Bool = false
    
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        VStack {
            List {
                Section("Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(user?.name ?? "")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(user?.email ?? "")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(user?.type == "A" ? "Admin" : (user?.type == "C" ? "Client" : "Producer") ?? "")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Security") {
                    if (session.user?.data.id != user?.id) {
                        Toggle(isOn: $locked, label: {
                            Text("Locked")
                        })
                        .tint(Theme.primary)
                    }
                    
                    Button("Reset Password") {}
                }
                
                Section {
                    EditButton()
                    if (session.user?.data.id != user?.id) {
                        Button("Delete", role: .destructive) {}
                    }
                }
            }
        }
        .onAppear() {
            locked = user!.locked == 1
        }
    }
}
