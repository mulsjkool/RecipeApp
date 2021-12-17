//
//  ListRecipeViewController.swift
//  RecipeApp
//
//  Created by Phùng Chịnh on 17/12/2021.
//

import UIKit
import RxSwift
import RxCocoa

class ListRecipeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let cellIdentifier = "ListRecipeCell"
    
    private let viewModel: ListRecipeViewModel
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: ListRecipeViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: "ListRecipeViewController", bundle: Bundle(for: ListRecipeViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupCollectionView()
        setAddButton()
        setLogoView()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let loadTrigger = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .take(1)
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = ListRecipeViewModel.Input(loadTrigger: loadTrigger)
        let output = viewModel.transform(input: input)
        
        disposeBag.addDisposables([
            output.recipes.drive(onNext: { _ in
                self.collectionView.reloadData()
            }),
            
            output.recipes.drive(collectionView.rx.items(cellIdentifier: cellIdentifier, cellType: ListRecipeCell.self)) { _, recipe, cell in
                cell.bind(recipe: recipe)
            }
        ])
    }
    
    private func setLogoView() {
        
        guard let nav = self.navigationController else { return }
        let image = UIImage(named: "logo_common")
        let imageView = UIImageView(image: image)
        let bannerWidth = nav.navigationBar.frame.size.width
        let bannerHeight = nav.navigationBar.frame.size.height

        let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
    }
    
    private func setAddButton() {
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ic_plus"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(addRecipe), for: .touchUpInside)
        button.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        let rightBarButtonItem = UIBarButtonItem(customView: button)

        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func setupCollectionView() {
        let nib = UINib(nibName: cellIdentifier, bundle: Bundle(for: ListRecipeCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
        
        collectionView.delegate = self
    }
    
    @objc private func addRecipe() {
        
    }
}

extension ListRecipeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = Utils.isLandscape ? collectionView.frame.width / 2 : collectionView.frame.width
        let padding: CGFloat = Utils.isLandscape ? 24 : 16 * 2
        return CGSize(width: width - padding, height: 200)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

}
