//
//  TrainingExamplesService.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 02/01/2023.
//

import Foundation

class TrainingExamplesService {
    
    static func post(userId: Int, accessToken: String, parameters: Data) async throws -> Void {
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/training-examples",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            parameters: parameters,
            method: "POST"
        )
    }
    
}
