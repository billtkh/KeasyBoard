//
//  BoardViewController.swift
//  KeasyBoardTests
//
//  Created by Bill Tsang on 25/10/2021.
//

import UIKit
@testable import KeasyBoard

class BoardViewController: UIViewController {
    
    var boardView: KeasyBoardView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        boardView = KeasyBoardView.createBoardView(inputViewController: nil,
                                                        textDocumentProxy: nil)
        view.addSubview(boardView)
        
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
}
