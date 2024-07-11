//
//  Affiliates.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import Foundation

struct Affiliate: Codable, Identifiable {
    var id: Int
    var name, email, energyPrice: String

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case energyPrice = "energy_price"
    }
}

typealias Affiliates = [Affiliate]
