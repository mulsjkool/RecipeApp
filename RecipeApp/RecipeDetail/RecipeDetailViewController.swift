//
//  RecipeDetailViewController.swift
//  RecipeApp
//
//  Created by Tung Phan on 19/12/2021.
//

import UIKit
import RxCocoa
import RxSwift

class RecipeDetailViewController: UIViewController {

    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var nameRecipeTextView: UITextView!
    @IBOutlet weak var descRecipeTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var pickerStackView: UIStackView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!

    
    private let viewModel: RecipeDetailViewModel
    private let disposeBag = DisposeBag()
    
    var saveCompletion: ((Recipe) -> Void)?
    var deletedCompletion: ((Recipe) -> Void)?
    
    private var selectedImagePublishSubject = PublishSubject<UIImage>()
    private var selectedImage: UIImage? {
        didSet {
            self.recipeImageView.image = selectedImage
            
            if let image = selectedImage {
                self.selectedImagePublishSubject.onNext(image)
            }
        }
    }
    private let imagePickerVC = UIImagePickerController()
    
    init(viewModel: RecipeDetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: "RecipeDetailViewController", bundle: Bundle(for: RecipeDetailViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func bindViewModel() {
        let loadTrigger = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .take(1)
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let selectCategory = selectButton.rx.tap.withLatestFrom(pickerView.rx.itemSelected).flatMapLatest { row, _ -> Driver<Int> in
            self.pickerStackView.isHidden = !self.pickerStackView.isHidden
            return Driver.just(row)
        }.asDriverOnErrorJustComplete()
        
        let input = RecipeDetailViewModel.Input(loadTrigger: loadTrigger, name: nameRecipeTextView.rx.text.orEmpty.asDriver(), desc: descRecipeTextView.rx.text.orEmpty.asDriver(), image: selectedImagePublishSubject.asDriverOnErrorJustComplete(), saveTrigger: saveButton.rx.tap.asDriver(), deleteTrigger: deleteButton.rx.tap.asDriver(), selectCategory: selectCategory)
        let output = viewModel.transform(input: input)
        
        disposeBag.addDisposables([
            
            output.recipe.drive(recipeBinding),
            output.save.drive(onNext: { [weak self] recipe in
                self?.saveCompletion?(recipe)
            }),
            output.delete.drive(onNext: { [weak self] recipe in
                self?.deletedCompletion?(recipe)
            }),
            
            categoryButton.rx.tap.subscribe(onNext: {
                self.pickerStackView.isHidden = !self.pickerStackView.isHidden
            }),
            
            output.categories.asObservable().bind(to: self.pickerView.rx.itemTitles) { _, element in
                return element.name
            },

            output.selectedCategory.drive(onNext: {
                self.categoryButton.setTitle("Category: \($0.name)", for: .normal)
                self.categoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            })
        ])
    }

    var recipeBinding: Binder<Recipe> {
        return Binder(self, binding: { (vc, recipe) in
            vc.title = recipe.name
            if let image = UIImage(data: recipe.image) {
                vc.recipeImageView.image = image
            }
            vc.nameRecipeTextView.text = recipe.name
            vc.descRecipeTextView.text = recipe.desc
            self.saveButton.setTitle(recipe.id.isEmpty ? "Save" : "Update", for: .normal)
            
            self.deleteButton.isHidden = recipe.id.isEmpty
//            
//            if let index = Int(recipe.category) {
//                self.pickerView.selectRow(index, inComponent: 0, animated: false)
//            }
            
        })
    }
    
    private func setupUI() {
        self.recipeImageView.isUserInteractionEnabled = true
        let showOptionsImagePicker = UITapGestureRecognizer(target: self, action: #selector(showOptionsImagePicker))
        self.recipeImageView.addGestureRecognizer(showOptionsImagePicker)
    }
    
    @objc private func showOptionsImagePicker() {
        let alert = UIAlertController(title: "", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
            self.showImagePicker(sourceType: .camera)
        }))
        
        alert.addAction(UIAlertAction(title: "PhotoLibrary", style: .default , handler:{ (UIAlertAction)in
            self.showImagePicker(sourceType: .photoLibrary)
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
            imagePickerVC.sourceType = sourceType
            imagePickerVC.delegate = self
            imagePickerVC.allowsEditing = true
            navigationController?.present(imagePickerVC, animated: true, completion: nil)
        }
}

extension RecipeDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            self.selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.selectedImage = originalImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
