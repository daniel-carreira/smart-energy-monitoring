//
//  AffiliateAddView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 05/01/2023.
//

import SwiftUI

struct AffiliateAddView: View {
    var onCompletion: () -> Void
    
    @State private var email = ""
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    @Environment(\.dismiss) var dismiss
    
    func create() -> Void {
        Task {
            do {
                let encode = try JSONEncoder().encode(["email": email])
                try await AffiliateService.add(userId: session.user!.data.id, accessToken: session.accessToken!, parameters: encode)
                onCompletion()
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
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }
            }
            .navigationBarTitle("Add", displayMode: .inline)
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
            .alert("Add failed", isPresented: $didFail, actions: {
                Button("Ok") {}
            }, message: {
                Text(failMessage)
            })
        }
    }
}
