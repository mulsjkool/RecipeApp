//
//  ListRecipeUseCaseMock.swift
//  RecipeAppTests
//
//  Created by Tung Phan on 19/12/2021.
//

import Foundation
@testable import RecipeApp
import RxSwift
import RxCocoa

class ListRecipeUseCaseMock: ListRecipeUseCase {
        
    var recicpes_Value: [Recipe] = [
        Recipe(id: UUID().uuidString, name: "Recipe 1", desc: "Recipe 1", image: Data(), category: "1"),
        Recipe(id: UUID().uuidString, name: "Recipe 2", desc: "Recipe 2", image: Data(), category: "2"),
        Recipe(id: UUID().uuidString, name: "Recipe 3", desc: "Recipe 3", image: Data(), category: "3"),
        Recipe(id: UUID().uuidString, name: "Recipe 4", desc: "Recipe 4", image: Data(), category: "4"),
    ]
    var categories_Value: [RecipeCategory] = [
        RecipeCategory(id: "1", name: "Breakfast"),
        RecipeCategory(id: "2", name: "Lunch"),
        RecipeCategory(id: "3", name: "Soups"),
        RecipeCategory(id: "4", name: "Salads"),
    ]

    func fetchRecipes(_ category: RecipeCategory?) -> [Recipe] {
        
        if let category = category {
            return recicpes_Value.filter({ $0.category == category.id })
        }
        return recicpes_Value
    }
    
    func fetchCategoriesFromXmlFile() -> [RecipeCategory] {
        return categories_Value
    }
}
