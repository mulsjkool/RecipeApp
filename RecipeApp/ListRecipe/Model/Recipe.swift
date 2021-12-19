//
//  Recipe.swift
//  RecipeApp
//
//  Created by Tung Phan on 17/12/2021.
//

import Foundation

public class Recipe: Equatable {
    
    public let id: String
    public var name: String
    public var desc: String
    public var image: Data
    public var category: String
    
    public init(id: String, name: String, desc: String, image: Data, category: String = "") {
        self.id = id
        self.name = name
        self.desc = desc
        self.image = image
        self.category = category
    }
        
    public static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
}
