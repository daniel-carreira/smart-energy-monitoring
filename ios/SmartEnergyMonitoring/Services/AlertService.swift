//
//  AlertService.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 30/12/2022.
//

import Foundation

class AlertService {
    
    static func fetchAll(userId: Int, accessToken: String) async throws -> Alerts {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/alerts",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: Alerts.self
        )
        
    }
}
