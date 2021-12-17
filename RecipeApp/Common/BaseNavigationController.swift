//
//  BaseNavigationController.swift
//  RecipeApp
//
//  Created by Phùng Chịnh on 17/12/2021.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = false
        view.backgroundColor = .white
        navigationBar.tintColor = .black
        
    }
}
