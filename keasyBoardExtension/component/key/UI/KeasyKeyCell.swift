//
//  KeasyKeyCell.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import UIKit

protocol KeasyKeyCellActionDelegate: AnyObject {
    func keyCell(_ keyCell: KeasyKeyCell, didTap keyPair: KeasyKeyPairViewModel)
}

class KeasyKeyCell: UICollectionViewCell {
    weak var actionDelegate: KeasyKeyCellActionDelegate?
    var viewModel: KeasyKeyPairViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            updateUI(viewModel: viewModel)
        }
    }
    
    private var keyView: UIView!
    
    private var mainLabel: UILabel!
    private var subLabel: UILabel!
    
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
        
        mainLabel = UILabel(frame: .zero)
        mainLabel.textColor = .white
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        keyView.addSubview(mainLabel)
        NSLayoutConstraint.activate(
            [
                mainLabel.centerXAnchor.constraint(equalTo: keyView.centerXAnchor),
                mainLabel.bottomAnchor.constraint(equalTo: keyView.bottomAnchor, constant: -4)
            ]
        )
        
        subLabel = UILabel(frame: .zero)
        subLabel.textColor = .white.withAlphaComponent(0.8)
        subLabel.font = .systemFont(ofSize: 10)
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        keyView.addSubview(subLabel)
        NSLayoutConstraint.activate(
            [
                subLabel.leadingAnchor.constraint(equalTo: keyView.leadingAnchor, constant: 4),
                subLabel.topAnchor.constraint(equalTo: keyView.topAnchor, constant: 4)
            ]
        )
        
        keyView.layer.cornerRadius = 5
        keyView.backgroundColor = UIColor(rgb: 0x2B2D2F)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        keyView.addGestureRecognizer(tapGesture)
    }
    
    func updateUI(viewModel: KeasyKeyPairViewModel) {
        mainLabel.text = viewModel.main.title
        subLabel.text = viewModel.sub?.title
        
        switch viewModel.main.key {
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
