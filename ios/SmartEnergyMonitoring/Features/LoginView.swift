//
//  LoginView.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 05/10/2022.
//

import SwiftUI


struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        ZStack {
            Theme.background.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 290)
                    .scaledToFit()
                Spacer()
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                    .font(.title3)
                    .foregroundColor(Theme.text)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.detailBackground)
                    .cornerRadius(15)
                    .padding(.top)
                
                SecureField("Password", text: $password)
                    .padding(.horizontal)
                    .font(.title3)
                    .foregroundColor(Theme.text)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.detailBackground)
                    .cornerRadius(15)
                    .padding(.top)
                
                Button(action: {
                    Task {
                        do {
                            try await session.signIn([
                                "username": email,
                                "password": password
                            ])
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
                    
                }, label: {
                    PrimaryButton(title: "Log In →")
                        .padding(.vertical)
                })
                .alert("Authentication failed", isPresented: $didFail, actions: {
                    Button("Retry") {
                        password = ""
                    }	
                }, message: {
                    Text(failMessage)
                })
                
                Button(action: {
                    session.register()
                }, label: {
                    Text("Don't have an account? Register here").foregroundColor(Theme.primary)
                })
    
            }
            .padding()
        }
        
    }

}
