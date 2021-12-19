//
//  ListRecipeUseCase.swift
//  RecipeApp
//
//  Created by Chinh IT. Phung Van on 19/12/2021.
//

import UIKit
import RxSwift
import RxCocoa
import AEXML
import CoreData

protocol ListRecipeUseCase {
    func fetchRecipes(_ category: RecipeCategory?) -> [Recipe]
    func fetchCategoriesFromXmlFile() -> [RecipeCategory]
}

class DefaultListRecipeUseCase: ListRecipeUseCase {
    
    private let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func fetchRecipes(_ category: RecipeCategory? = nil) -> [Recipe] {
        
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
            
            return recipes.map { entity in
                return Recipe(id: entity.id ?? "", name: entity.name ?? "", desc: entity.desc ?? "", image: entity.image ?? Data(), category: entity.category ?? "")
            }

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func fetchCategoriesFromXmlFile() -> [RecipeCategory] {
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
                return RecipeCategory(dict: $0)
            })
            
            return categories
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
}
