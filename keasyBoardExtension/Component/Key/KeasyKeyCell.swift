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
            textLabel.text = viewModel?.key.rawValue
        }
    }
    
    private var textLabel: UILabel!
    
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
        textLabel = UILabel(frame: .zero)
        textLabel.textColor = .white
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        NSLayoutConstraint.activate(
            [
                textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ]
        )
        
        contentView.backgroundColor = .systemBlue
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func tapAction() {
        guard let viewModel = viewModel else { return }
        actionDelegate?.keyCell(self, didTap: viewModel)
    }
}
