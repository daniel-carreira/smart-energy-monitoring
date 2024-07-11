//
//  DivisionCreateView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 05/01/2023.
//

import SwiftUI

struct DivisionCreateView: View {
    var onCompletition: () -> Void
    @State private var name = ""
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    @Environment(\.dismiss) var dismiss
    
    func create() -> Void {
        Task {
            do {
                let encode = try JSONEncoder().encode(["name": name])
                try await DivisionService.create(userId: session.user!.data.id, accessToken: session.accessToken!, parameters: encode)
                onCompletition()
                dismiss()
            }
            catch APIHelper.APIError.invalidRequestError(let errorMessage) {
                failMessage = errorMessage
                didFail = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    TextField("Division name", text: $name)
                }
            }
            .navigationBarTitle("Create", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        create()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert("Create failed", isPresented: $didFail, actions: {
                Button("Ok") {}
            }, message: {
                Text(failMessage)
            })
        }
    }
}
