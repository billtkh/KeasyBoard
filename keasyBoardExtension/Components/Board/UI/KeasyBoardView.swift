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
    
    private var styleManager: KeasyStyleManager {
        return KeasyStyleManager.shared
    }
    
    init(viewModel: KeasyBoardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupUI()
        setupStyle()
        binding()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = KeasyBoardViewModel(textDocumentProxy: nil, needsInputModeSwitchKey: false)
        super.init(frame: .zero)
        
        setupUI()
        setupStyle()
        binding()
    }
    
    func updateNeedsInputModeSwitchKey(_ needsInputModeSwitchKey: Bool) {
        viewModel.setNeedsInputModeSwitchKey(needsInputModeSwitchKey)
    }
}

private extension KeasyBoardView {
    func binding() {
        viewModel.currentState.bind { [weak self] state in
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                switch state {
                case let .wordSelecting(words, page), let .shiftLockOnAndWordSelecting(words, page):
                    sSelf.viewModel.selectingWords(words, page: page)
                    sSelf.collectionView.reloadData()
                default:
                    sSelf.collectionView.reloadData()
                }
            }
        }
        
        viewModel.needsInputModeSwitchKey.bind { [weak self] needsInputModeSwitchKey in
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.viewModel.reloadDataSource()
                sSelf.collectionView.reloadData()
            }
        }
    }
    
    func setupUI() {
        let keyboardLayout = UICollectionViewFlowLayout()
        keyboardLayout.minimumInteritemSpacing = viewModel.keySpacing
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
        backgroundColor = styleManager.backgroundColor
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
        keyCell.viewModel = keyViewModel
        return keyCell
    }
}

extension KeasyBoardView: KeasyKeyCellActionDelegate {
    func keyCell(_ keyCell: KeasyKeyCell, didTap keyPair: KeasyKeyPairViewModel) {
        viewModel.didTap(keyPair: keyPair)
    }
    
    func keyCell(_ keyCell: KeasyKeyCell, didLongPress keyPair: KeasyKeyPairViewModel) {
        viewModel.didLongPress(keyPair: keyPair)
    }
}
