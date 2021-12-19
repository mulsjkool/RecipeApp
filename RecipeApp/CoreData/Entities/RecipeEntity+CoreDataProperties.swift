//
//  RecipeEntity+CoreDataProperties.swift
//  
//
//  Created by Tung Phan on 19/12/2021.
//
//

import Foundation
import CoreData


extension RecipeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeEntity> {
        return NSFetchRequest<RecipeEntity>(entityName: "RecipeEntity")
    }

    @NSManaged public var desc: String?
    @NSManaged public var id: String?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var category: String?
    
    public convenience init() {
        self.init()
    }

}
