//
//  Recipe.swift
//  RecipeApp
//
//  Created by Tung Phan on 17/12/2021.
//

import Foundation

class Recipe: Equatable {
    
    let id: String
    var name: String
    var desc: String
    var image: Data
    var category: String
    
    init(id: String, name: String, desc: String, image: Data, category: String = "") {
        self.id = id
        self.name = name
        self.desc = desc
        self.image = image
        self.category = category
    }
        
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
}
