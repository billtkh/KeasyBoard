//
//  KeasyBoardViewController.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import UIKit

class KeasyBoardViewController: UIInputViewController {    
    var boardView: KeasyBoardView!
    
    private var spacingManager: KeasySpacingManager {
        return KeasySpacingManager.shared
    }
    
    private var styleManager: KeasyStyleManager {
        return KeasyStyleManager.shared
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initStyleManager()
        let viewModel = KeasyBoardViewModel(textDocumentProxy: textDocumentProxy,
                                            needsInputModeSwitchKey: needsInputModeSwitchKey)
        boardView = KeasyBoardView(viewModel: viewModel)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupKeyboardHeight()
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
        
    }
}

private extension KeasyBoardViewController {
    func initStyleManager() {
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            styleManager.currentStyle = .light
        case .dark:
            styleManager.currentStyle = .dark
        default:
            styleManager.currentStyle = .light
        }
    }
    
    func setupUI() {
        guard let inputView = inputView else { return }
        inputView.addSubview(boardView)
        
        boardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                boardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                boardView.topAnchor.constraint(equalTo: view.topAnchor),
                boardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                boardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
    
    func setupKeyboardHeight() {
        let heightConstraint = boardView.heightAnchor.constraint(equalToConstant: spacingManager.boardHeight)
        heightConstraint.priority = .required - 1
        heightConstraint.isActive = true
    }
}
