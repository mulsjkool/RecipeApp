//
//  ListRecipeViewModel.swift
//  RecipeApp
//
//  Created by Phùng Chịnh on 17/12/2021.
//

import Foundation
import RxCocoa

class ListRecipeViewModel: ViewModelType {
    
    private(set) var recipes = [Recipe]()
    
    func transform(input: Input) -> Output {
        
        let data = [Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "D82D40"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "90AF17"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "2DBBD8"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "D82D40"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "90AF17"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "2DBBD8"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "D82D40"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "90AF17"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "2DBBD8"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "D82D40"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "90AF17"), Recipe(id: "1", name: "Pizza", desc: "Pizza description", image: "cook_new", backgroundColor: "2DBBD8")]
        
        let recipes = input.loadTrigger.flatMapLatest({ _ -> Driver<[Recipe]> in
            return .just(data)
        })
        
        return Output(recipes: recipes)
    }
}

extension ListRecipeViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
    }
    
    struct Output {
        let recipes: Driver<[Recipe]>
    }
}
