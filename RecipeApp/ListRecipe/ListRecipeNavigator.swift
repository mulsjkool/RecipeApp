//
//  ListRecipeNavigator.swift
//  RecipeApp
//
//  Created by Tung Phan on 19/12/2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum RecipeState {
    case update(Recipe)
    case delete(Recipe)
}

class ListRecipeNavigator {
    
    private let navigation: UINavigationController
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func goRecipeDetail(_ recipe: Recipe, categories: [Category]) -> Driver<RecipeState> {
        
        let publishSubject = PublishSubject<RecipeState>()
        let viewModel = RecipeDetailViewModel(recipe: recipe, categories: categories)
        let detailVc = RecipeDetailViewController(viewModel: viewModel)
        detailVc.saveCompletion = { [weak self] item in
            publishSubject.onNext(.update(item))
            
            self?.navigation.popViewController(animated: true)
        }
        
        detailVc.deletedCompletion = { [weak self] item in
            publishSubject.onNext(.delete(item))
            self?.navigation.popViewController(animated: true)
        }

        navigation.pushViewController(detailVc, animated: true)
        
        return publishSubject.asDriverOnErrorJustComplete()
    }
    
    func goCreateRecipe(categories: [Category]) -> Driver<Recipe> {
        
        let publishSubject = PublishSubject<Recipe>()
        let viewModel = RecipeDetailViewModel(recipe: Recipe(id: "", name: "", desc: "", image: Data()), categories: categories)
        let detailVc = RecipeDetailViewController(viewModel: viewModel)
        detailVc.saveCompletion = { [weak self] item in
            publishSubject.onNext(item)
            
            self?.navigation.popViewController(animated: true)
        }
        
        navigation.pushViewController(detailVc, animated: true)
        
        return publishSubject.asDriverOnErrorJustComplete()
    }
}
