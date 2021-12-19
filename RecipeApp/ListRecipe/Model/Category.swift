//
//  Category.swift
//  RecipeApp
//
//  Created by Tung Phan on 19/12/2021.
//

import Foundation

struct Category {
    let id: String
    let name: String
}

extension Category {
    init(dict: [String : String]) {
        self.id = dict["id"] ?? ""
        self.name = dict["name"] ?? ""
    }
}
