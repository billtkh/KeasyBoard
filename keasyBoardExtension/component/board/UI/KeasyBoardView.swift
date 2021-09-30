//
//  KeasyBoardView.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 30/9/2021.
//

import Foundation
import UIKit

class KeasyBoardView: UIView {
    var collectionView: UICollectionView!
    var viewModel: KeasyBoardViewModel
    
    init(viewModel: KeasyBoardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupUI()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = KeasyBoardViewModel(textDocumentProxy: nil)
        super.init(frame: .zero)
        
        setupUI()
        setupStyle()
    }
}

extension KeasyBoardView {
    func setupUI() {
        let keyboardLayout = UICollectionViewFlowLayout()
        keyboardLayout.minimumInteritemSpacing = viewModel.keyPadding
        keyboardLayout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: keyboardLayout)
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )

        collectionView.register(KeasyKeyCell.self, forCellWithReuseIdentifier: NSStringFromClass(KeasyKeyCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupStyle() {
        backgroundColor = UIColor(red: 214, green: 216, blue: 222)
        collectionView.backgroundColor = .clear
    }
}

extension KeasyBoardView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.insetOfSection(in: collectionView, section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.sizeForItem(in: collectionView, at: indexPath)
    }
}

extension KeasyBoardView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let keyCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(KeasyKeyCell.self), for: indexPath) as? KeasyKeyCell else { return UICollectionViewCell(frame: .zero) }
        keyCell.actionDelegate = self
        
        let keyViewModel = viewModel.keyViewModelAt(indexPath: indexPath)
        keyViewModel.isToggleOn.bind { [weak self] isToggle in
            guard self != nil else { return }
            keyCell.toggle(isToggle)
        }
        keyCell.viewModel = keyViewModel
        return keyCell
    }
}

extension KeasyBoardView: KeasyKeyCellActionDelegate {
    func keyCell(_ keyCell: KeasyKeyCell, didTap keyPair: KeasyKeyPairViewModel) {
        viewModel.didTap(keyPair: keyPair)
    }
}
