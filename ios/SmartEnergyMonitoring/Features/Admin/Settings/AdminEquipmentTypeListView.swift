//
//  AdminEquipmentTypeListView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 31/12/2022.
//

import SwiftUI

struct AdminEquipmentTypeListView: View {
    @State private var equipmentTypes: EquipmentTypes?
    @State private var equipmentTypesLoading = true
    
    @State private var selectedEquipmentType: EquipmentType?
    @State private var showEquipementType = false
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    func fetchEquipmentTypes() {
        Task {
            do {
                equipmentTypesLoading = true
                equipmentTypes = try await EquipmentTypeService.fetchAll(accessToken: session.accessToken!)
                equipmentTypesLoading = false
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                failMessage = errorMessage
                didFail = true
            }
            catch APIHelper.APIError.decodingError {
                failMessage = "Decoding Error"
                didFail = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Theme.background.edgesIgnoringSafeArea(.top)
                
                if (equipmentTypesLoading) {
                    ProgressView()
                }
                else {
                    List {
                        Section {
                            ForEach(equipmentTypes?.data ?? []) { equipmentType in
                                Button(action: {
                                    selectedEquipmentType = equipmentType
                                    showEquipementType = true
                                }, label: {
                                    HStack {
                                        Text(equipmentType.name)
                                            .foregroundColor(Theme.text)
                                        Spacer()
                                        Symbols.arrow
                                            .foregroundColor(.gray)
                                    }
                                })
                            }
                        }
                    }
                }
            }
            .navigationTitle("Equipment Types")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        
                    }
                    label: {
                        Symbols.plus
                        Text("New")
                    }
                }
            }
            .onAppear() {
                fetchEquipmentTypes()
            }
            .alert("Data fetch failed", isPresented: $didFail, actions: {
                Button("Ok") {}
            }, message: {
                Text(failMessage)
            })
            .sheet(isPresented: $showEquipementType, content: {
                AdminEquipmentTypeView(equipmentType: $selectedEquipmentType)
            })
        }
    }
}
