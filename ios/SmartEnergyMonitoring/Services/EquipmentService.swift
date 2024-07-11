//
//  EquipmentService.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 11/12/2022.
//

import Foundation

class EquipmentService {
    
    static func fetch(userId: Int, accessToken: String) async throws -> Equipments {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/equipments",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: Equipments.self
        )
        
    }
    
    static func patch(userId: Int, accessToken: String, equipmentId: Int, parameters: Data) async throws -> Void {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/equipments/\(equipmentId)",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            parameters: parameters,
            method: "PATCH"
        )
        
    }
    
    static func patchSocket(userId: Int, accessToken: String, equipmentId: Int, parameters: Data) async throws -> Void {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/equipments/\(equipmentId)/socket",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            parameters: parameters,
            method: "PATCH"
        )
        
    }
    
    static func create(userId: Int, accessToken: String, parameters: Data) async throws -> Void {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/equipments",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            parameters: parameters,
            method: "POST"
        )
        
    }
    
    static func update(userId: Int, accessToken: String, equipmentId: Int, parameters: Data) async throws -> Void {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/equipments/\(equipmentId)",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            parameters: parameters,
            method: "PUT"
        )
        
    }
    
    
    static func delete(userId: Int, accessToken: String, equipmentId: Int) async throws -> Void {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/equipments/\(equipmentId)",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "DELETE"
        )
        
    }
    
}
