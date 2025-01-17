//
//  KeasyBoardView.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 30/9/2021.
//

import Foundation
import UIKit
import RxSwift

public class KeasyBoardView: UIView {
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
    
    private lazy var emojiPicker: EmojiView = {
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        keyboardSettings.countOfRecentsEmojis = 10
        keyboardSettings.needToShowAbcButton = true
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        setupEmojiPicker(emojiView)
        return emojiView
    }()
    
    init(viewModel: KeasyBoardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupUI()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = KeasyBoardViewModel(inputViewController: nil,
                                             textDocumentProxy: nil,
                                             needsInputModeSwitchKey: false)
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
            .distinctUntilChanged()
            .debounce(RxTimeInterval.milliseconds(10),
                      scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler())
            .subscribe { [weak self] needsInputModeSwitchKey in
                guard let sSelf = self else { return }
                sSelf.viewModel.reloadDataSource()
                sSelf.collectionView.reloadData()
            }
        .disposed(by: disposeBag)
        
        _ = viewModel.shouldDisplayEmojiPicker
            .distinctUntilChanged()
            .observe(on: MainScheduler())
            .subscribe { [weak self] shouldDisplay in
                guard let sSelf = self else { return }
                guard let shouldDisplay = shouldDisplay.element else { return }
                sSelf.setEmojiPicker(isHidden: !shouldDisplay)
            }
        
        functionBar.binding()
    }
}

private extension KeasyBoardView {
    func setupUI() {
        clipsToBounds = false
        
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
                functionBar.heightAnchor.constraint(equalToConstant: KeasySpacingManager.shared.space(.barHeight))
            ]
        )
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                collectionView.topAnchor.constraint(equalTo: functionBar.bottomAnchor),
                collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                collectionView.heightAnchor.constraint(equalToConstant: KeasySpacingManager.shared.space(.boardHeight) - KeasySpacingManager.shared.space(.barHeight))
            ]
        )

        collectionView.register(KeasyKeyCell.self, forCellWithReuseIdentifier: NSStringFromClass(KeasyKeyCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupEmojiPicker(_ emojiView: EmojiView) {
        emojiView.delegate = viewModel
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emojiView)
        NSLayoutConstraint.activate(
            [
                emojiView.leadingAnchor.constraint(equalTo: leadingAnchor),
                emojiView.topAnchor.constraint(equalTo: topAnchor),
                emojiView.trailingAnchor.constraint(equalTo: trailingAnchor),
                emojiView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        )
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
    
    func setEmojiPicker(isHidden: Bool) {
        emojiPicker.isHidden = isHidden
        collectionView.isHidden = !isHidden
        functionBar.isHidden = !isHidden
    }
}

extension KeasyBoardView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.insetOfSection(in: collectionView, section: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.sizeForItem(in: collectionView, at: indexPath)
    }
}

extension KeasyBoardView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let keyCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(KeasyKeyCell.self), for: indexPath) as? KeasyKeyCell else { return UICollectionViewCell(frame: .zero) }
        keyCell.actionDelegate = self
        
        let viewModel = viewModel.viewModelAt(indexPath: indexPath)
        keyCell.viewModel = viewModel
        return keyCell
    }
}

extension KeasyBoardView: KeasyKeyCellActionDelegate {
    func keyCell(_ keyCell: KeasyKeyCell, didTap keyPair: KeasyKeyPairViewModel) {
        viewModel.didTap(keyPair: keyPair, from: keyCell)
    }
    
    func keyCell(_ keyCell: KeasyKeyCell, didLongPress keyPair: KeasyKeyPairViewModel) {
        viewModel.didLongPress(keyPair: keyPair, from: keyCell)
    }
}

extension KeasyBoardView: KeasyFunctionBarActionDelegate {
    func functionBar(_ functionBar: KeasyFunctionBar, didInvoke tab: KeasyTabViewModel) {
        viewModel.handleTab(tab)
    }
}

extension KeasyBoardView {
    static func createBoardView(inputViewController: UIInputViewController?,
                                textDocumentProxy: UITextDocumentProxy?) -> KeasyBoardView {
        let viewModel = KeasyBoardViewModel(inputViewController: inputViewController,
                                            textDocumentProxy: textDocumentProxy,
                                            needsInputModeSwitchKey: true)
        return KeasyBoardView(viewModel: viewModel)
    }
}
