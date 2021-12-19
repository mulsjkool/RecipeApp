//
//  ListRecipeViewModel.swift
//  RecipeApp
//
//  Created by Tung Phan on 17/12/2021.
//

import Foundation
import RxCocoa
import AEXML
import CoreData

class ListRecipeViewModel: ViewModelType {
    
    private(set) var recipes = [Recipe]()
    private let navigator: ListRecipeNavigator
    private let useCase: ListRecipeUseCase
    
    init(navigator: ListRecipeNavigator, useCase: ListRecipeUseCase) {
        self.navigator = navigator
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        
        let categories = input.loadTrigger.flatMapLatest { _ -> Driver<[RecipeCategory]> in
            let data = self.useCase.fetchCategoriesFromXmlFile()
            return Driver.just(data)
        }
        
        let allRecipes = input.loadTrigger.flatMapLatest { _ -> Driver<[Recipe]> in
            let data = self.useCase.fetchRecipes(nil)
            return Driver.just(data)
        }
        
        let filterRecipes = input.selectCategory.withLatestFrom(categories, resultSelector: { index, categories in
            return categories[index]
        })
            .flatMapLatest({ category -> Driver<[Recipe]> in
                let data = self.useCase.fetchRecipes(category)
                return .just(data)
            })
        
        let selectedRecipe = input.selection.withLatestFrom(categories) { (indexPath, categories) -> (Recipe, [RecipeCategory]) in
            return (self.recipes[indexPath.row], categories)
        }.flatMapLatest { tuple -> Driver<RecipeState> in
            return self.navigator.goRecipeDetail(tuple.0, categories: tuple.1)
        }.flatMapLatest { state -> Driver<Recipe> in
            switch state {
            case .update(let recipe):
                if let index = self.recipes.firstIndex(of: recipe) {
                    self.recipes[index] = recipe
                }
                return .just(recipe)
            case .delete(let recipe):
                if let index = self.recipes.firstIndex(of: recipe) {
                    self.recipes.remove(at: index)
                }
                return .just(recipe)
            }
        }
        
        let createRecipe = input.createRecipe.withLatestFrom(categories).flatMapLatest { categories in
            self.navigator.goCreateRecipe(categories: categories)
        }.flatMapLatest({ item -> Driver<Recipe> in
            self.recipes.append(item)
            return Driver.just(item)
        })
        
        let updateRecipes = Driver.merge(selectedRecipe, createRecipe)
            .flatMapLatest { _ -> Driver<[Recipe]> in
                return Driver.just(self.recipes)
            }
        
        let recipes = Driver.merge(allRecipes, filterRecipes, updateRecipes)
            .do(onNext: {
                self.recipes = $0
            })
        
        return Output(recipes: recipes, categories: categories)
                }
}

extension ListRecipeViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let selection: Driver<IndexPath>
        let selectCategory: Driver<Int>
        let createRecipe: Driver<Void>
    }
    
    struct Output {
        let recipes: Driver<[Recipe]>
//        let selectedRecipe: Driver<Recipe>
        let categories: Driver<[RecipeCategory]>
//        let createRecipe: Driver<Void>
    }
}
