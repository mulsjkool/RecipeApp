//
//  ListRecipeViewModel.swift
//  RecipeApp
//
//  Created by Phùng Chịnh on 17/12/2021.
//

import Foundation
import RxCocoa
import AEXML
import CoreData

class ListRecipeViewModel: ViewModelType {
    
    private(set) var recipes = [Recipe]()
    private let navigator: ListRecipeNavigator
    let persistentContainer: NSPersistentContainer
    
    init(navigator: ListRecipeNavigator) {
        self.navigator = navigator
        persistentContainer = NSPersistentContainer(name: "RecipeApp")
    }
    
    func transform(input: Input) -> Output {
        
        let categories = input.loadTrigger.flatMapLatest { _ -> Driver<[Category]> in
            let data = self.fetchCategoriesFromXmlFile()
            return Driver.just(data)
        }
        
        let allRecipes = input.loadTrigger.flatMapLatest { _ -> Driver<[Recipe]> in
            let data = self.fetchRecipes()
                .map { entity in
                    return Recipe(id: entity.id?.uuidString ?? "", name: entity.name ?? "", desc: entity.desc ?? "", image: entity.image ?? Data())
                }
            return Driver.just(data)
        }
        
        let filterRecipes = input.selectCategory.withLatestFrom(categories, resultSelector: { index, categories in
            return categories[index]
        })
            .flatMapLatest({ category -> Driver<[Recipe]> in
            let data = self.fetchRecipes(category)
                    .map { entity in
                        return Recipe(id: entity.id?.uuidString ?? "", name: entity.name ?? "", desc: entity.desc ?? "", image: entity.image ?? Data())
                    }
            return .just(data)
        })
        
        let recipes = Driver.merge(allRecipes, filterRecipes)
        
        let recipesAndCategories = Driver.combineLatest(recipes, categories)
            let selectedRecipe = input.selection.withLatestFrom(recipesAndCategories) { (indexPath, recipesAndCategories) -> (Recipe, [Category]) in
                return (recipesAndCategories.0[indexPath.row], recipesAndCategories.1)
            }.flatMapLatest {
                return self.navigator.goRecipeDetail($0.0, categories: $0.1)
            }
            
            let createRecipe = input.createRecipe.withLatestFrom(categories).flatMapLatest { categories in
                self.navigator.goCreateRecipe(categories: categories)
            }.mapToVoid()
        
            return Output(recipes: recipes, selectedRecipe: selectedRecipe, categories: categories, createRecipe: createRecipe)
    }
    
    private func fetchRecipes(_ category: Category? = nil) -> [RecipeEntity] {
        
        //1
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return []
                }
        
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
        NSFetchRequest<RecipeEntity>(entityName: "RecipeEntity")
        
        if let category = category, !category.id.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "category == %@", category.id)
        }
        
        //3
        do {
            let recipes = try managedContext.fetch(fetchRequest)
            
            return recipes
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    private func fetchCategoriesFromXmlFile() -> [Category] {
        guard let xmlPath = Bundle.main.path(forResource: "recipetypes", ofType: "xml"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath))
        else { return [] }
        
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            let elements = xmlDoc.root.children.map({ $0.children })
            let dicts = elements.map({
                return Dictionary(uniqueKeysWithValues: $0.lazy.map { ($0.name, $0.string) })
            })
            
            let categories = dicts.map({
                return Category(dict: $0)
            })
            
            return categories
        } catch let error {
            print(error.localizedDescription)
            return []
        }
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
        let selectedRecipe: Driver<Recipe>
        let categories: Driver<[Category]>
        let createRecipe: Driver<Void>
    }
}
