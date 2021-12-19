//
//  ListRecipeViewModelTest.swift
//  RecipeAppTests
//
//  Created by Chinh IT. Phung Van on 19/12/2021.
//

import XCTest
@testable import RecipeApp
import RxSwift
import RxCocoa

class ListRecipeViewModelTest: XCTestCase {
    
    var viewModel: ListRecipeViewModel!
    var useCase: ListRecipeUseCaseMock!
    var navigator: ListRecipeNavigatorMock!
    
    var disposeBag = DisposeBag()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        useCase = ListRecipeUseCaseMock()
        navigator = ListRecipeNavigatorMock()
        viewModel = ListRecipeViewModel(navigator: navigator, useCase: useCase)
    }

    func test_fetch_recipe_types() {
        
        let loadTrigger = PublishSubject<Void>()
        
        let input = ListRecipeViewModel.Input(loadTrigger: loadTrigger.asDriverOnErrorJustComplete(), selection: .empty(), selectCategory: .empty(), createRecipe: .empty())
        
        let output = viewModel.transform(input: input)
        
        var countCategories = 0
        disposeBag.addDisposables([
            output.categories.drive(onNext: {
                countCategories = $0.count
            })
        ])
        loadTrigger.onNext(())
        XCTAssertTrue(countCategories > 0)
    }
    
    func test_all_recipes() {
        
        let loadTrigger = PublishSubject<Void>()
        
        let input = ListRecipeViewModel.Input(loadTrigger: loadTrigger.asDriverOnErrorJustComplete(), selection: .empty(), selectCategory: .empty(), createRecipe: .empty())
        
        let output = viewModel.transform(input: input)
        
        var countAllRecipes = 0
        disposeBag.addDisposables([
            output.recipes.drive(onNext: {
                countAllRecipes = $0.count
            })
        ])
        
        loadTrigger.onNext(())
        XCTAssertTrue(countAllRecipes == useCase.recicpes_Value.count)
    }
    
    func test_filter_recipes() {
        
        let loadTrigger = PublishSubject<Void>()
        let selectCategory = PublishSubject<Int>()
        let input = ListRecipeViewModel.Input(loadTrigger: loadTrigger.asDriverOnErrorJustComplete(), selection: .empty(), selectCategory: selectCategory.asDriverOnErrorJustComplete(), createRecipe: .empty())
        
        let output = viewModel.transform(input: input)
        
        var countFilterRecipes = 0
        disposeBag.addDisposables([
            output.recipes.drive(onNext: {
                countFilterRecipes = $0.count
            })
        ])
        
        loadTrigger.onNext(())
        selectCategory.onNext(1)
        XCTAssertTrue(countFilterRecipes == 1)
    }

    func test_create_recipe() {
        let loadTrigger = PublishSubject<Void>()
        let createRecipe = PublishSubject<Void>()
        let input = ListRecipeViewModel.Input(loadTrigger: loadTrigger.asDriverOnErrorJustComplete(), selection: .empty(), selectCategory: .empty(), createRecipe: createRecipe.asDriverOnErrorJustComplete())
        
        let output = viewModel.transform(input: input)
        
        var countAllRecipes = 0
        disposeBag.addDisposables([
            output.recipes.drive(onNext: {
                countAllRecipes = $0.count
            })
        ])
        
        loadTrigger.onNext(())
        createRecipe.onNext(())
        XCTAssertTrue(countAllRecipes > useCase.recicpes_Value.count)
    }
    
    func test_delete_recipe() {
        let loadTrigger = PublishSubject<Void>()
        let selection = PublishSubject<IndexPath>()
        let input = ListRecipeViewModel.Input(loadTrigger: loadTrigger.asDriverOnErrorJustComplete(), selection: selection.asDriverOnErrorJustComplete(), selectCategory: .empty(), createRecipe: .empty())
        
        let output = viewModel.transform(input: input)
        
        var countAllRecipes = 0
        disposeBag.addDisposables([
            output.recipes.drive(onNext: {
                countAllRecipes = $0.count
            })
        ])
        navigator.recipe_Value = useCase.recicpes_Value[1]
        navigator.isUpdate = false
        loadTrigger.onNext(())
        selection.onNext(IndexPath(item: 1, section: 0))
        XCTAssertTrue(countAllRecipes < useCase.recicpes_Value.count)
    }

    
}
