//
//  KeasyBoardView.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 30/9/2021.
//

import Foundation
import UIKit

class KeasyBoardView: UIView {
    var boardView: UICollectionView!
    var functionBar: UICollectionView!
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
                default:
                    sSelf.boardView.reloadData()
                }
            }
        }
        
        viewModel.currentWordSelection.bind { [weak self] selection in
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                guard let selection = selection else {
                    sSelf.reloadSelectionData()
                    return
                }
                sSelf.viewModel.selectingWords(selection.words, page: selection.page)
                sSelf.reloadSelectionData()
            }
        }
        
        viewModel.needsInputModeSwitchKey.bind { [weak self] needsInputModeSwitchKey in
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.viewModel.reloadDataSource()
                sSelf.boardView.reloadData()
            }
        }
    }
    
    func setupUI() {
        let functionBarLayout = UICollectionViewFlowLayout()
        functionBarLayout.minimumInteritemSpacing = viewModel.keySpacing
        functionBarLayout.minimumLineSpacing = 0
        functionBar = UICollectionView(frame: .zero, collectionViewLayout: functionBarLayout)
        addSubview(functionBar)
        
        let keyboardLayout = UICollectionViewFlowLayout()
        keyboardLayout.minimumInteritemSpacing = viewModel.keySpacing
        keyboardLayout.minimumLineSpacing = 0
        boardView = UICollectionView(frame: .zero, collectionViewLayout: keyboardLayout)
        addSubview(boardView)
        
        functionBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                functionBar.leadingAnchor.constraint(equalTo: leadingAnchor),
                functionBar.topAnchor.constraint(equalTo: topAnchor),
                functionBar.trailingAnchor.constraint(equalTo: trailingAnchor),
                functionBar.heightAnchor.constraint(equalToConstant: KeasySpacingManager.shared.functionBarHeight)
            ]
        )
        
        boardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                boardView.leadingAnchor.constraint(equalTo: leadingAnchor),
                boardView.topAnchor.constraint(equalTo: functionBar.bottomAnchor),
                boardView.trailingAnchor.constraint(equalTo: trailingAnchor),
                boardView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )

        boardView.register(KeasyKeyCell.self, forCellWithReuseIdentifier: NSStringFromClass(KeasyKeyCell.self))
        boardView.delegate = self
        boardView.dataSource = self
    }
    
    func setupStyle() {
        backgroundColor = styleManager.backgroundColor
        boardView.backgroundColor = .clear
    }
    
    func reloadSelectionData() {
        UIView.performWithoutAnimation {
            boardView.reloadSections(IndexSet(integer: 0))
        }
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
