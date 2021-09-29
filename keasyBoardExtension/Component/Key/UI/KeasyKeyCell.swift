//
//  KeasyKeyCell.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import UIKit

protocol KeasyKeyCellActionDelegate: AnyObject {
    func keyCell(_ keyCell: KeasyKeyCell, didTap keyViewModel: KeasyKeyViewModel)
}

class KeasyKeyCell: UICollectionViewCell {
    weak var actionDelegate: KeasyKeyCellActionDelegate?
    var viewModel: KeasyKeyViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            updateUI(viewModel: viewModel)
        }
    }
    
    private var keyView: UIView!
    
    private var textLabel: UILabel!
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
}

private extension KeasyKeyCell {
    func setupUI() {
        keyView = UIView(frame: .zero)
        keyView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(keyView)
        NSLayoutConstraint.activate(
            [
                keyView.topAnchor.constraint(equalTo: contentView.topAnchor),
                keyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ]
        )
        
        leadingConstraint = keyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        leadingConstraint.isActive = true
        trailingConstraint = keyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        trailingConstraint.isActive = true
        
        textLabel = UILabel(frame: .zero)
        textLabel.textColor = .white
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        keyView.addSubview(textLabel)
        NSLayoutConstraint.activate(
            [
                textLabel.centerXAnchor.constraint(equalTo: keyView.centerXAnchor),
                textLabel.bottomAnchor.constraint(equalTo: keyView.bottomAnchor, constant: -4)
            ]
        )
        
        keyView.backgroundColor = .systemBlue
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        keyView.addGestureRecognizer(tapGesture)
    }
    
    func updateUI(viewModel: KeasyKeyViewModel) {
        textLabel.text = viewModel.key.rawValue
        
        switch viewModel.key {
        case .shift:
            trailingConstraint.constant = -4
        case .backspace:
            leadingConstraint.constant = 4
        default:
            break
        }
    }
    
    @objc
    func tapAction() {
        guard let viewModel = viewModel else { return }
        actionDelegate?.keyCell(self, didTap: viewModel)
    }
}
