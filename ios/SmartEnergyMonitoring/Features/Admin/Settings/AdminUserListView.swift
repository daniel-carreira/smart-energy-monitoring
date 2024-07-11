//
//  AdminUserListView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 31/12/2022.
//

import SwiftUI

struct AdminUserListView: View {
    @State var users: Users?
    @State var usersLoading = true
    
    @State var selectedType: UserType = .Admin
    
    @State var selectedUser: UserClass?
    @State var showUser = false
    
    @State private var didFail = false
    @State private var failMessage = ""
    
    @EnvironmentObject var session: SessionManager
    
    enum UserType: String, CaseIterable {
        case Client = "C"
        case Admin = "A"
        case Producer = "P"
    }
    
    func fetchUserData() -> Void {
        Task {
            do {
                usersLoading = true
                users = try await UserService.fetchAll(accessToken: session.accessToken!)
                usersLoading = false
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
                
                if (usersLoading) {
                    ProgressView()
                }
                else {
                    List {
                        Section {
                            Picker("Consumption", selection: $selectedType) {
                                Text("Admin").tag(UserType.Admin)
                                Text("Client").tag(UserType.Client)
                                Text("Producer").tag(UserType.Producer)
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        Section {
                            ForEach(users?.data.filter { $0.type == selectedType.rawValue } ?? []) { user in
                                Button(action: {
                                    selectedUser = user
                                    showUser = true
                                }, label: {
                                    HStack {
                                        Text(user.email)
                                            .foregroundColor(Theme.text)
                                        Spacer()
                                        Symbols.arrow
                                            .foregroundStyle(.gray)
                                    }
                                })
                            }
                        }
                    }
                }
            }
            .navigationTitle("Users")
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
                fetchUserData()
            }
            .alert("Data fetch failed", isPresented: $didFail, actions: {
                Button("Ok") {}
            }, message: {
                Text(failMessage)
            })
            .sheet(isPresented: $showUser, content: {
                AdminUserView(user: $selectedUser)
            })
        }
    }
}
