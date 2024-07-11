//
//  HelpUsView.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import SwiftUI

struct ObservationView: View {
    @Binding var observation: Observation?
    @Binding var divisions: Set<DivisionShort>
    
    @State private var title: String = ""
    
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        HStack {
                            Text("Date")
                            Spacer()
                            Text(unixTimestampToFormatedString(observation?.consumption.timestamp))
                                .foregroundStyle(.secondary)
                        }
                    }
                    ForEach(Array(divisions)) { division in
                        Section(division.name) {
                            ForEach(observation?.observation.equipments.filter { $0.consumption != "0.00" && $0.division == division.id } ?? []) { equipment in
                                HStack {
                                    Text(equipment.name)
                                    Spacer()
                                    Text("\(equipment.consumption) W")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear() {
                let formatedDate = unixTimestampToFormatedString(observation?.consumption.timestamp)
                title = "Observation of " + formatedDate
            }
            .navigationBarItems(trailing:
                Button("Close") {
                    dismiss()
                }
            )
            .navigationBarTitle("Energy Activity", displayMode: .inline)
        }
    }
}
