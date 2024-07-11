//
//  EquipmentTypeService.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 31/12/2022.
//

import Foundation

class EquipmentTypeService {
    
    static func fetchAll(accessToken: String) async throws -> EquipmentTypes {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/equipment-types",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: EquipmentTypes.self
        )
        
    }
}
