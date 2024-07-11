//
//  SessionManager.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import SwiftUI

@MainActor
final class SessionManager: ObservableObject {
    
    enum CurrentState {
        case loggedIn
        case loggedOut
        case register
        case remember
    }
    
    @Published private(set) var currentState: CurrentState?
    @Published private(set) var accessToken: String?
    @Published var user: User?
    
    func signIn(_ credentials: [String: String]) async throws {
        
        let auth: Auth = try await AuthService.login(credentials: credentials)
        KeychainHelper.standard.save(Data(auth.accessToken.utf8), service: "access-token", account: "sem")
        accessToken = auth.accessToken
        user = try await UserService.fetch(accessToken: auth.accessToken)
        currentState = .loggedIn
    }
    
    func signOut() {
        accessToken = ""
        KeychainHelper.standard.delete(service: "access-token", account: "sem")
        currentState = .loggedOut
    }
    
    func register() {
        currentState = .register
    }
    
    func rememberLogin() async throws {
        currentState = .remember
        
        let data: Data? = KeychainHelper.standard.read(service: "access-token", account: "sem")
        if (data == nil) {
            currentState = .loggedOut
            return
        }
        
        accessToken = String(decoding: data!, as: UTF8.self)
        user = try await UserService.fetch(accessToken: accessToken!)
        currentState = .loggedIn
    }
    
    //Aux function to return login view
    func loginPage() {
        currentState = .loggedOut
    }
    
    func refreshUser() async throws{
        user = try await UserService.fetch(accessToken: accessToken!)
    }
    
}
