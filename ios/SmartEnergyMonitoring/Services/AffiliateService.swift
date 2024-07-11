//
//  AffiliateService.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 10/12/2022.
//

import Foundation

class AffiliateService {
    
    static func fetch(userId: Int, accessToken: String) async throws -> Affiliates {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/affiliates",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: Affiliates.self
        )
        
    }
    
    static func fetchMyAffiliates(userId: Int, accessToken: String) async throws -> Affiliates {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/affiliates/my",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "GET",
            type: Affiliates.self
        )
        
    }
    
    static func add(userId: Int, accessToken: String, parameters: Data) async throws -> Void {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/affiliates",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            parameters: parameters,
            method: "POST"
        )
        
    }
    
    static func delete(userId: Int, accessToken: String, affiliateId: Int) async throws -> Void {
        
        return try await APIHelper.request(
            url: "https://smartenergymonitoring.dei.estg.ipleiria.pt/api/users/\(userId)/affiliates/\(affiliateId)",
            headers: ["Accept":"application/json",
                      "Content-Type":"application/json",
                      "Authorization":"Bearer \(accessToken)"],
            method: "DELETE"
        )
        
    }
    
}
