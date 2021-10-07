//
//  KeasyBoardView.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 30/9/2021.
//

import Foundation
import UIKit
import RxSwift

class KeasyBoardView: UIView {
    var collectionView: UICollectionView!
    var functionBar: KeasyFunctionBar!
    
    var viewModel: KeasyBoardViewModel
    
    let disposeBag = DisposeBag()
    
    private var styleManager: KeasyStyleManager {
        return KeasyStyleManager.shared
    }
    
    private var imeManager: KeasyInputMethodManager {
        return KeasyInputMethodManager.shared
    }
    
    init(viewModel: KeasyBoardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupUI()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = KeasyBoardViewModel(textDocumentProxy: nil, needsInputModeSwitchKey: false)
        super.init(frame: .zero)
        
        setupUI()
        setupStyle()
    }
    
    func updateNeedsInputModeSwitchKey(_ needsInputModeSwitchKey: Bool) {
        viewModel.setNeedsInputModeSwitchKey(needsInputModeSwitchKey)
    }
    
    func binding() {
        _ = viewModel.currentState
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(50),
                      scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler())
            .subscribe { [weak self] state in
            guard let sSelf = self else { return }
            switch state {
            default:
                sSelf.collectionView.reloadData()
            }
        }
        .disposed(by: disposeBag)
        
        _ = viewModel.currentWordSelection
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(50),
                      scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler())
            .subscribe { [weak self] event in
            guard let sSelf = self else { return }
            guard let selection = event.element as? KeasyWordSelection else {
                sSelf.reloadSelectionData()
                return
            }
            
            sSelf.viewModel.selectingWords(selection.words, page: selection.page)
            sSelf.reloadSelectionData()
        }
        .disposed(by: disposeBag)
        
        _ = viewModel.needsInputModeSwitchKey
            .observe(on: MainScheduler())
            .subscribe { [weak self] needsInputModeSwitchKey in
            guard let sSelf = self else { return }
            sSelf.viewModel.reloadDataSource()
            sSelf.collectionView.reloadData()
        }
        .disposed(by: disposeBag)
        
        functionBar.binding()
    }
}

private extension KeasyBoardView {
    func setupUI() {
        functionBar = KeasyFunctionBar(viewModel: KeasyFunctionBarViewModel(board: viewModel))
        functionBar.delegate = self
        addSubview(functionBar)
        
        let keyboardLayout = UICollectionViewFlowLayout()
        keyboardLayout.minimumInteritemSpacing = viewModel.keySpacing
        keyboardLayout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: keyboardLayout)
        addSubview(collectionView)
        
        functionBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                functionBar.leadingAnchor.constraint(equalTo: leadingAnchor),
                functionBar.topAnchor.constraint(equalTo: topAnchor),
                functionBar.trailingAnchor.constraint(equalTo: trailingAnchor),
                functionBar.heightAnchor.constraint(equalToConstant: KeasySpacingManager.shared.barHeight)
            ]
        )
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                collectionView.topAnchor.constraint(equalTo: functionBar.bottomAnchor),
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
        functionBar.backgroundColor = .clear
        collectionView.backgroundColor = .clear
    }
    
    func reloadSelectionData() {
        UIView.performWithoutAnimation {
            collectionView.reloadSections(IndexSet(integer: 0))
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
        
        let viewModel = viewModel.viewModelAt(indexPath: indexPath)
        keyCell.viewModel = viewModel
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

extension KeasyBoardView: KeasyFunctionBarActionDelegate {
    func functionBar(_ functionBar: KeasyFunctionBar, didInvoke tab: KeasyTabViewModel) {
        viewModel.handleTab(tab)
    }
}
