//
//  UserStatService.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 11/12/2022.
//

import Foundation

class UserStatService {
    
    static func fetch(userId: Int, accessToken: String) async throws -> UserStats {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/statistics/kwh?months=2",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: UserStats.self
        )
        
    }
    
    static func fetchAll(userId: Int, accessToken: String) async throws -> UserStats {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/statistics/kwh?months=6",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: UserStats.self
        )
        
    }
    
}
