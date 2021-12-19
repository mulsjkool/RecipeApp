//
//  ListRecipeNavigatorMock.swift
//  RecipeAppTests
//
//  Created by Chinh IT. Phung Van on 19/12/2021.
//

import Foundation
@testable import RecipeApp
import RxSwift
import RxCocoa

class ListRecipeNavigatorMock: ListRecipeNavigator {
    
    var recipe_Value: Recipe = Recipe(id: UUID().uuidString, name: "Test 1", desc: "Test 1", image: Data())    
    var isUpdate: Bool = false
    
    func goRecipeDetail(_ recipe: Recipe, categories: [RecipeCategory]) -> Driver<RecipeState> {
        return Driver.just(isUpdate ? .update(recipe_Value) : .delete(recipe_Value))
    }
    
    var create_Recipe_Value: Recipe = Recipe(id: UUID().uuidString, name: "Test 1", desc: "Test 1", image: Data(), category: "4")
    func goCreateRecipe(categories: [RecipeCategory]) -> Driver<Recipe> {
        return Driver.just(create_Recipe_Value)
    }
}
