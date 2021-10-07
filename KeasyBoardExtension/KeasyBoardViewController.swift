//
//  KeasyBoardViewController.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import UIKit

class KeasyBoardViewController: UIInputViewController {    
    var boardView: KeasyBoardView!
    var didBindViewModel = false
    
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
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            print(paths[0])
        
        initStyleManager()
        
        let viewModel = KeasyBoardViewModel(textDocumentProxy: textDocumentProxy,
                                            needsInputModeSwitchKey: true)
        boardView = KeasyBoardView(viewModel: viewModel)
        
        setupKeyboardHeight()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        KeasyFeedbackManager.shared.prepare()
        
        bindViewModel()
        boardView.updateNeedsInputModeSwitchKey(needsInputModeSwitchKey)
    }
    
    override func viewWillLayoutSubviews() {
//        boardView.updateNeedsInputModeSwitchKey(needsInputModeSwitchKey)
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
    func bindViewModel() {
        guard !didBindViewModel else { return }
        boardView.binding()
        didBindViewModel = true
    }
    
    func initStyleManager() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if let keyboardAppearance = textDocumentProxy.keyboardAppearance {
            switch (keyboardAppearance, userInterfaceStyle) {
            case (.light, _), (.default, .light):
                styleManager.currentStyle = .light
            case (.dark, _), (.default, .dark):
                styleManager.currentStyle = .dark
            default:
                styleManager.currentStyle = .light
            }
        } else {
            switch userInterfaceStyle {
            case .light, .unspecified:
                styleManager.currentStyle = .light
            case .dark:
                styleManager.currentStyle = .dark
            default:
                styleManager.currentStyle = .light
            }
        }
    }
    
    func setupUI() {
        guard let inputView = inputView else { return }
        inputView.addSubview(boardView)
        
        boardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                boardView.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
                boardView.topAnchor.constraint(equalTo: inputView.topAnchor),
                boardView.trailingAnchor.constraint(equalTo: inputView.trailingAnchor),
                boardView.bottomAnchor.constraint(equalTo: inputView.bottomAnchor)
            ]
        )
    }
    
    func setupKeyboardHeight() {
        let heightConstraint = boardView.heightAnchor.constraint(equalToConstant: spacingManager.boardHeight)
        heightConstraint.priority = .required - 1
        heightConstraint.isActive = true
    }
}

