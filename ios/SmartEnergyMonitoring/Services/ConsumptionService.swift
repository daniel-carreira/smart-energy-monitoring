//
//  ConsumptionService.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 11/12/2022.
//

import Foundation

class ConsumptionService {
    
    static func fetch(userId: Int, accessToken: String) async throws -> Consumptions {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/consumptions?limit=24",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: Consumptions.self
        )
        
    }
    
    static func fetchWithInterval(userId: Int, accessToken: String, interval: String) async throws -> [ConsumptionInterval] {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/consumptions?limit=24&interval=\(interval)",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: [ConsumptionInterval].self
        )
        
    }
}
