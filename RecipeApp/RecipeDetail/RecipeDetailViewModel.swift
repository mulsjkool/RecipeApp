//
//  RecipeDetailViewModel.swift
//  RecipeApp
//
//  Created by Tung Phan on 19/12/2021.
//

import Foundation
import RxCocoa
import CoreData

class RecipeDetailViewModel: ViewModelType {
    
    private let recipe: Recipe
    let categories: [RecipeCategory]
    
    init(recipe: Recipe, categories: [RecipeCategory]) {
        self.recipe = recipe
        self.categories = categories
    }
    
    func transform(input: Input) -> Output {
        
        let categories = input.loadTrigger.flatMapLatest {
            return Driver.just(self.categories)
        }
        
        let defaultCategory = input.loadTrigger.flatMapLatest { _ -> Driver<RecipeCategory> in
            if let category = self.categories.first(where: { self.recipe.category == $0.id }) {
                return Driver.just(category)
            } else {
                return Driver.empty()
            }
        }
        
        let selectedCategory = input.selectCategory.withLatestFrom(categories, resultSelector: { index, categories in
            return categories[index]
        })

        let image = Driver.merge(Driver.just(UIImage(data: recipe.image) ?? UIImage()), input.image)
        
        let nameAndDesc = Driver.combineLatest(input.name, input.desc, image, Driver.merge(defaultCategory, selectedCategory))
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
                
                if recipe.id.isEmpty {
                    if self.save(recipe: recipe) {
                        return Driver.just(recipe)
                    } else {
                        return Driver.empty()
                    }
                } else {
                    if self.update(recipe: recipe) {
                        return Driver.just(recipe)
                    } else {
                        return Driver.empty()
                    }
                }
            }
        
        let delete = input.deleteTrigger.withLatestFrom(recipe).flatMapLatest { recipe -> Driver<Recipe> in
            
            if self.delete(recipe: recipe) {
                return Driver.just(recipe)
            } else {
                return Driver.empty()
            }
        }
                        
        return Output(recipe: recipe, save: save, delete: delete, categories: categories, selectedCategory: Driver.merge(defaultCategory, selectedCategory))
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
            object.setValue(UUID().uuidString, forKeyPath: "id")
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
    
    func update(recipe: Recipe) -> Bool {
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return false
                }
        
        // 1
        let context =
        appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecipeEntity")
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", recipe.id)
        
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if let recipes = results, !recipes.isEmpty {
                
                recipes[0].setValue(recipe.name, forKeyPath: "name")
                recipes[0].setValue(recipe.desc, forKeyPath: "desc")
                recipes[0].setValue(recipe.image, forKeyPath: "image")
                recipes[0].setValue(recipe.category, forKeyPath: "category")
                
                do {
                    try context.save()
                    return true
                }
                catch {
                    print("Saving Core Data Failed: \(error)")
                    
                }
                
            }
        } catch {
            print("Fetch Failed: \(error)")
            
        }
        return false
    }
    
    private func delete(recipe: Recipe) -> Bool {
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return false
                }
        
        // 1
        let context =
        appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecipeEntity")
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", recipe.id)
        
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if let recipes = results, !recipes.isEmpty {
                for object in recipes {
                    context.delete(object)
                }
                
                try context.save()
                return true
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        return false
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
        let categories: Driver<[RecipeCategory]>
        let selectedCategory: Driver<RecipeCategory>
    }
}
