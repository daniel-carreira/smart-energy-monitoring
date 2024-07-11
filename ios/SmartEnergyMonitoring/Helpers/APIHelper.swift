//
//  APIHelper.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 28/11/2022.
//

import Foundation

class APIHelper {
    
    enum APIError: LocalizedError {
        case invalidRequestError(String)
        case transportError(Error)
        case decodingError
    }
    
    static func request<T: Decodable>(url: String, headers: [String: String] = [:], parameters: [String: String] = [:], method: String, type: T.Type) async throws -> T {

        var request = URLRequest(url: URL(string: url)!)
        
        // Method
        request.httpMethod = method
        
        // Headers
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        // Body
        if (!parameters.isEmpty) {
            let postData = try? JSONEncoder().encode(parameters)
            request.httpBody = postData
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)

        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw APIError.invalidRequestError("Invalid data! (Status Code: \(response.statusCode))")
        }
        
        guard let result = try? JSONDecoder().decode(T.self, from: data) else {
            throw APIError.decodingError
        }
        
        return(result)
    }
    
    static func request(url: String, headers: [String: String] = [:], parameters: Data, method: String) async throws -> Void {

        var request = URLRequest(url: URL(string: url)!)
        
        // Method
        request.httpMethod = method
        
        // Headers
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        // Body
        request.httpBody = parameters
        
        let (_, response) = try await URLSession.shared.data(for: request)

        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw APIError.invalidRequestError("Invalid data! (Status Code: \(response.statusCode))")
        }
    }
    
    static func request(url: String, headers: [String: String] = [:], method: String) async throws -> Void {

        var request = URLRequest(url: URL(string: url)!)
        
        // Method
        request.httpMethod = method
        
        // Headers
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        
        let (_, response) = try await URLSession.shared.data(for: request)

        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw APIError.invalidRequestError("Invalid data! (Status Code: \(response.statusCode))")
        }
    }
    
}
