//
//  DivisionListView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 10/12/2022.
//

import SwiftUI

struct DivisionListView: View {
    @State private var showCreate = false
    @State private var divisions: Divisions?
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @State private var showDelete = false
    @State private var selected: Division?
    
    @EnvironmentObject var session: SessionManager
    
    func deleteDivision(divisionId: Int) {
        Task {
            do {
                try await DivisionService.delete(userId: session.user!.data.id, accessToken: session.accessToken!, divisionId: divisionId)
                divisions?.data.remove(at: (divisions?.data.firstIndex(where: { $0.id == divisionId }))!)
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                failMessage = errorMessage
                didFail = true
            }
        }
    }
    
    func fetchDivisions() {
        Task {
            do {
                divisions = try await DivisionService.fetch(userId: session.user!.data.id, accessToken: session.accessToken!)
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
        
        ZStack {
            
            Theme.background.edgesIgnoringSafeArea(.top)
            
            List {
                
                ForEach(divisions?.data ?? []) { division in
                    HStack {
                        Text(division.name)
                        Spacer()
                        Button {
                            selected = division
                            showDelete = true
                        } label: {
                            Symbols.trash
                        }
                    }
                }
                
            }
            
        }
        .navigationTitle("Divisions")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showCreate = true
                }
                label: {
                    Symbols.plus
                    Text("New")
                }
            }
        }
        .onAppear() {
            
            fetchDivisions()
            
        }
        .alert("Data fetch failed", isPresented: $didFail, actions: {
            Button("Ok") {}
        }, message: {
            Text(failMessage)
        })
        .alert("Are you sure?", isPresented: $showDelete, actions: {
            Button("Delete", role: .destructive) {
                deleteDivision(divisionId: selected!.id)
            }
        }, message: {
            Text("Delete \(selected?.name ?? "") from your divisions")
        })
        .sheet(isPresented: $showCreate, content: {
            DivisionCreateView(onCompletition: { fetchDivisions() })
        })
        
    }
}
