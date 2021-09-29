//
//  KeasyBoardViewController.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import UIKit

class KeasyBoardViewController: UIInputViewController {
    
    var viewModel = KeasyBoardViewModel()
    
    var collectionView: UICollectionView!
    
    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: viewModel.boardHeight)
        heightConstraint.priority = .required - 1
        heightConstraint.isActive = true
    }
    
    override func viewWillLayoutSubviews() {
//        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

}

private extension KeasyBoardViewController {
    func setupUI() {
        let keyboardLayout = UICollectionViewFlowLayout()
        keyboardLayout.minimumInteritemSpacing = viewModel.keyPadding
        keyboardLayout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: keyboardLayout)
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )

        collectionView.register(KeasyKeyCell.self, forCellWithReuseIdentifier: NSStringFromClass(KeasyKeyCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension KeasyBoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.insetOfSection(in: collectionView, section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.sizeForItem(in: collectionView, at: indexPath)
    }
}

extension KeasyBoardViewController: UICollectionViewDataSource {
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

extension KeasyBoardViewController: KeasyKeyCellActionDelegate {
    func keyCell(_ keyCell: KeasyKeyCell, didTap keyPair: KeasyKeyPairViewModel) {
        textDocumentProxy.insertText(keyPair.main.title)
    }
}
