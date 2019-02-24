//
//  FactionResponse.swift
//  RoasterhammerShared
//
//  Created by Thibault Klein on 2/24/19.
//

import Foundation

public struct FactionDTO {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct FactionResponse: Codable {
    public let id: Int
    public let name: String
    public let rules: [RuleResponse]

    public init(faction: FactionDTO, rules: [RuleResponse]) throws {
        self.id = faction.id
        self.name = faction.name
        self.rules = rules
    }
}
