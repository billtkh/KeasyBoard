//
//  KeasyFunctionBar.swift
//  KeasyBoardExtension
//
//  Created by Bill Tsang on 7/10/2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol KeasyFunctionBarActionDelegate: AnyObject {
    func functionBar(_ functionBar: KeasyFunctionBar, didInvoke tab: KeasyTabViewModel)
}

class KeasyFunctionBar: UIView {
    var collectionView: UICollectionView!
    var viewModel: KeasyFunctionBarViewModel
    
    weak var delegate: KeasyFunctionBarActionDelegate?
    
    let disposeBag = DisposeBag()
    
    private var imeManager: KeasyInputMethodManager {
        return KeasyInputMethodManager.shared
    }
    
    init(viewModel: KeasyFunctionBarViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let functionBarLayout = UICollectionViewFlowLayout()
        functionBarLayout.minimumInteritemSpacing = viewModel.keySpacing
        functionBarLayout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: functionBarLayout)
        addSubview(collectionView)
        
        let keyboardLayout = UICollectionViewFlowLayout()
        keyboardLayout.minimumInteritemSpacing = viewModel.keySpacing
        keyboardLayout.scrollDirection = .horizontal
        keyboardLayout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: keyboardLayout)
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                collectionView.heightAnchor.constraint(equalToConstant: KeasySpacingManager.shared.space(.barHeight))
            ]
        )
        
        collectionView.register(KeasyTabCell.self, forCellWithReuseIdentifier: NSStringFromClass(KeasyTabCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .clear
    }
    
    func binding() {
        _ = imeManager.inputBuffer
            .observe(on: MainScheduler())
            .subscribe { [weak self] inputBuffer in
            guard let sSelf = self else { return }
            sSelf.viewModel.reloadDataSource()
            sSelf.collectionView.reloadData()
        }
        .disposed(by: disposeBag)
    }
}

extension KeasyFunctionBar: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.insetOfSection(in: collectionView, section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.sizeForItem(in: collectionView, at: indexPath)
    }
}

extension KeasyFunctionBar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tabCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(KeasyTabCell.self), for: indexPath) as? KeasyTabCell else { return UICollectionViewCell(frame: .zero) }
        tabCell.actionDelegate = self
        
        let viewModel = viewModel.viewModelAt(indexPath: indexPath)
        tabCell.viewModel = viewModel
        return tabCell
    }
}

extension KeasyFunctionBar: KeasyTabCellActionDelegate {
    func tabCell(_ tabCell: KeasyTabCell, didTap tab: KeasyTabViewModel) {
        viewModel.didTap(tab: tab)
    }
    
    func tabCell(_ tabCell: KeasyTabCell, didLongPress tab: KeasyTabViewModel) {
        viewModel.didLongPress(tab: tab)
    }
}
