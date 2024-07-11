//
//  AdminStatsService.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 31/12/2022.
//

import Foundation

class AdminStatsService {
    
    static func fetch(accessToken: String) async throws -> AdminStats {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/statistics",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: AdminStats.self
        )
        
    }
    
    static func fetchUsers(accessToken: String) async throws -> AdminStatsUsers {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/statistics/users",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: AdminStatsUsers.self
        )
        
    }
}
