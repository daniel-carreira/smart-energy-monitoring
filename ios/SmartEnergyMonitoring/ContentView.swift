//
//  ContentView.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var session = SessionManager()
    
    var body: some View {
        VStack {
            switch session.currentState {
            case .loggedIn:
                if (session.user?.data.type == "C") {
                    MainView()
                        .environmentObject(session)
                        .transition(.opacity)
                }
                else if (session.user?.data.type == "A") {
                    MainAdminView()
                        .environmentObject(session)
                        .transition(.opacity)
                }
            case .register:
                RegisterView()
                    .environmentObject(session)
                    .transition(.opacity)
            case .loggedOut:
                LoginView()
                    .environmentObject(session)
                    .transition(.opacity)
            default:
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .onAppear {
            Task {
                try await session.rememberLogin()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
