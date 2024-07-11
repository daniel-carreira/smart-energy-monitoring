//
//  UserService.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 04/12/2022.
//

import Foundation

class UserService {
    
    static func create(parameters: Data) async throws -> Void {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json"],
            parameters: parameters,
            method: "POST"
        )
        
    }
    
    static func fetch(accessToken: String) async throws -> User {
        
        let authUser = try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/user",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: UserClass.self
        )
        
        return User(data: authUser)
        
    }
    
    static func fetchAll(accessToken: String) async throws -> Users {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: Users.self
        )
        
    }
    
    static func update(userId: Int, accessToken: String, parameters: Data) async throws -> Void {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            parameters: parameters,
            method: "PUT"
        )
        
    }
    
    static func patchNotifications(userId: Int, accessToken: String, parameters: Data) async throws -> Void {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/notifications",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            parameters: parameters,
            method: "PATCH"
        )
        
    }
    
}
