//
//  Category.swift
//  RecipeApp
//
//  Created by Tung Phan on 19/12/2021.
//

import Foundation

public struct RecipeCategory {
    public let id: String
    public let name: String
}

extension RecipeCategory {
    public init(dict: [String : String]) {
        self.id = dict["id"] ?? ""
        self.name = dict["name"] ?? ""
    }
}
