//
//  AdminEquipmentTypeView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 31/12/2022.
//

import SwiftUI

struct AdminEquipmentTypeView: View {
    @Binding var equipmentType: EquipmentType?
    @State var activity: Activity = .Yes
    
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        VStack {
            List {
                Section("Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(equipmentType?.name ?? "")
                            .foregroundStyle(.secondary)
                    }
                    
                    Picker("Manual Activation", selection: $activity) {
                        Text("Yes").tag(Activity.Yes)
                        Text("No").tag(Activity.No)
                    }
                }
                
                Section {
                    EditButton()
                    Button("Delete", role: .destructive) {}
                }
            }
        }
        .onAppear() {
            activity = equipmentType!.activity
        }
    }
}
