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
            updateToggle(viewModel: viewModel)
        }
    }
    
    private var keyView: UIView!
    
    private var primaryLabel: UILabel!
    private var secondaryLabel: UILabel!
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    private var toggleView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    func toggle(_ istoggle: Bool) {
        toggleView.backgroundColor = istoggle ? .systemGreen : .gray
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
        
        primaryLabel = UILabel(frame: .zero)
        primaryLabel.textColor = .white
        primaryLabel.font = .systemFont(ofSize: 17)
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        keyView.addSubview(primaryLabel)
        NSLayoutConstraint.activate(
            [
                primaryLabel.centerXAnchor.constraint(equalTo: keyView.centerXAnchor),
                primaryLabel.bottomAnchor.constraint(equalTo: keyView.bottomAnchor, constant: -4)
            ]
        )
        
        secondaryLabel = UILabel(frame: .zero)
        secondaryLabel.textColor = .white.withAlphaComponent(0.8)
        secondaryLabel.font = .systemFont(ofSize: 10)
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        keyView.addSubview(secondaryLabel)
        NSLayoutConstraint.activate(
            [
                secondaryLabel.leadingAnchor.constraint(equalTo: keyView.leadingAnchor, constant: 4),
                secondaryLabel.topAnchor.constraint(equalTo: keyView.topAnchor, constant: 4)
            ]
        )
        
        keyView.layer.cornerRadius = 5
        keyView.backgroundColor = UIColor(rgb: 0x2B2D2F)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        keyView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(toggleAction))
        longPressGesture.minimumPressDuration = 0.75
        keyView.addGestureRecognizer(longPressGesture)
        
        tapGesture.require(toFail: longPressGesture)
        
        toggleView = UIView(frame: .zero)
        toggleView.layer.cornerRadius = 4
        toggleView.translatesAutoresizingMaskIntoConstraints = false
        toggleView.backgroundColor = .gray
        keyView.addSubview(toggleView)
        NSLayoutConstraint.activate(
            [
                toggleView.centerXAnchor.constraint(equalTo: keyView.centerXAnchor),
                toggleView.topAnchor.constraint(equalTo: keyView.topAnchor, constant: 6),
                toggleView.widthAnchor.constraint(equalToConstant: 8),
                toggleView.heightAnchor.constraint(equalToConstant: 8),
            ]
        )
    }
    
    func updateUI(viewModel: KeasyKeyPairViewModel) {
        primaryLabel.text = viewModel.main.title
        secondaryLabel.text = viewModel.sub?.title
        
        switch viewModel.main.titleSize {
        case .regular:
            primaryLabel.font = .systemFont(ofSize: 17)
        case .small:
            primaryLabel.font = .systemFont(ofSize: 10)
        }
        
        switch viewModel.main.key {
        case .shift:
            trailingConstraint.constant = -4
        case .delete:
            leadingConstraint.constant = 4
        default:
            break
        }
    }
    
    func updateToggle(viewModel: KeasyKeyPairViewModel) {
        toggleView.isHidden = viewModel.isToggleHidden
        toggle(viewModel.isToggleOn.value)
    }
    
    @objc
    func tapAction() {
        guard let viewModel = viewModel else { return }
        actionDelegate?.keyCell(self, didTap: viewModel)
    }
    
    @objc
    func toggleAction(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        guard let viewModel = viewModel else { return }
        viewModel.setToggle(!viewModel.isToggleOn.value)
    }
}
