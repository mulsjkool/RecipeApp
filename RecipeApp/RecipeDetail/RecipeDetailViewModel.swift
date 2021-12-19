//
//  RecipeDetailViewModel.swift
//  RecipeApp
//
//  Created by Chinh IT. Phung Van on 19/12/2021.
//

import Foundation
import RxCocoa
import CoreData

class RecipeDetailViewModel: ViewModelType {
    
    private let recipe: Recipe
    let categories: [Category]
    
    init(recipe: Recipe, categories: [Category]) {
        self.recipe = recipe
        self.categories = categories
    }
    
    func transform(input: Input) -> Output {
        
        let categories = input.loadTrigger.flatMapLatest {
            return Driver.just(self.categories)
        }

        let selectedCategory = input.selectCategory.withLatestFrom(categories, resultSelector: { index, categories in
            return categories[index]
        })

        let nameAndDesc = Driver.combineLatest(input.name, input.desc, input.image, selectedCategory)
        let recipe = Driver.combineLatest(Driver.just(self.recipe), nameAndDesc) { (recipe, nameAndDesc) -> Recipe in
            recipe.name = nameAndDesc.0
            recipe.desc = nameAndDesc.1
            
            if let data = nameAndDesc.2.pngData() {
                recipe.image = data
            }
            
            recipe.category = nameAndDesc.3.id
            
            return recipe
        }.startWith(self.recipe)
        
        let save = input.saveTrigger.withLatestFrom(recipe)
            .flatMapLatest { recipe -> Driver<Recipe> in
                if self.save(recipe: recipe) {
                    return Driver.just(recipe)
                } else {
                    return Driver.empty()
                }
            }
        
        let delete = input.deleteTrigger.withLatestFrom(recipe).flatMapLatest { recipe in
            return Driver.just(recipe)
        }
                        
        return Output(recipe: recipe, save: save, delete: delete, categories: categories, selectedCategory: selectedCategory)
    }
    
    func save(recipe: Recipe) -> Bool {
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return false
      }
      
      // 1
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      // 2
      let entity =
        NSEntityDescription.entity(forEntityName: "RecipeEntity",
                                   in: managedContext)!
      
      let object = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      
      // 3
        if recipe.id.isEmpty {
            object.setValue(UUID(), forKeyPath: "id")
        }
        
        object.setValue(recipe.name, forKeyPath: "name")
        object.setValue(recipe.desc, forKeyPath: "desc")
        object.setValue(recipe.image, forKeyPath: "image")
        object.setValue(recipe.category, forKeyPath: "category")
      
      // 4
      do {
        try managedContext.save()
//        people.append(person)
          return true
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
          return false
      }
    }
}

extension RecipeDetailViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let name: Driver<String>
        let desc: Driver<String>
        let image: Driver<UIImage>
        let saveTrigger: Driver<Void>
        let deleteTrigger: Driver<Void>
        let selectCategory: Driver<Int>
    }
    
    struct Output {
        let recipe: Driver<Recipe>
        let save: Driver<Recipe>
        let delete: Driver<Recipe>
        let categories: Driver<[Category]>
        let selectedCategory: Driver<Category>
    }
}
