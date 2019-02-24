//
//  RuleResponse.swift
//  RoasterhammerShared
//
//  Created by Thibault Klein on 2/24/19.
//

import Foundation

public struct RuleResponse: Codable {
    public let name: String
    public let description: String

    public init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}
