//
//  Recipe.swift
//  RecipeApp
//
//  Created by Phùng Chịnh on 17/12/2021.
//

import Foundation

class Recipe: Equatable {
    
    let id: String
    let name: String
    let desc: String
    let image: String
    let backgroundColor: String
    
    init(id: String, name: String, desc: String, image: String, backgroundColor: String) {
        self.id = id
        self.name = name
        self.desc = desc
        self.image = image
        self.backgroundColor = backgroundColor
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
}

/*
RecipeBundle(
  id: 1,
  chefs: 16,
  recipes: 95,
  title: "Cook Something New Everyday",
  description: "New and tasty recipes every minute",
  imageSrc: "assets/images/cook_new@2x.png",
  color: Color(0xFFD82D40),
),
RecipeBundle(
  id: 2,
  chefs: 8,
  recipes: 26,
  title: "Best of 2020",
  description: "Cook recipes for special occasions",
  imageSrc: "assets/images/best_2020@2x.png",
  color: Color(0xFF90AF17),
),
RecipeBundle(
  id: 3,
  chefs: 10,
  recipes: 43,
  title: "Food Court",
  description: "What's your favorite food dish make it now",
  imageSrc: "assets/images/food_court@2x.png",
  color: Color(0xFF2DBBD8),
),
*/
