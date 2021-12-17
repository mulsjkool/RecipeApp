//
//  ListRecipeCell.swift
//  RecipeApp
//
//  Created by Phùng Chịnh on 17/12/2021.
//

import UIKit

class ListRecipeCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 18
        containerView.clipsToBounds = true
    }

    func bind(recipe: Recipe) {
        containerView.backgroundColor = UIColor(hexString: recipe.backgroundColor)
        recipeImageView.image = UIImage(named: recipe.image)
        recipeNameLabel.text = recipe.name
        recipeDescriptionLabel.text = recipe.desc
    }
}
