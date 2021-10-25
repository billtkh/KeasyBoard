//
//  KeasyKeyCell.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import UIKit

protocol KeasyKeyCellActionDelegate: AnyObject {
    func keyCell(_ keyCell: KeasyKeyCell, didTap keyPair: KeasyKeyPairViewModel)
    func keyCell(_ keyCell: KeasyKeyCell, didLongPress keyPair: KeasyKeyPairViewModel)
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
    
    private var iconView: UIImageView!
    
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
    
    func toggle(state: KeasyToggleState) {
        switch state {
        case .off:
            toggleView.backgroundColor = styleManager.shiftOffColor
        case .on:
            toggleView.backgroundColor = styleManager.shiftOnColor
        case .locked:
            toggleView.backgroundColor = styleManager.shiftLockOnColor
        }
    }
}

private extension KeasyKeyCell {
    var styleManager: KeasyStyleManager {
        return KeasyStyleManager.shared
    }
    
    var spacingManager: KeasySpacingManager {
        return KeasySpacingManager.shared
    }
    
    var rowPadding: Double {
        return spacingManager.space(.rowPadding)
    }
    
    var keyPadding: Double {
        return spacingManager.space(.keyPadding)
    }
    
    var commonSpacing: Double {
        return spacingManager.space(.common)
    }
    
    var narrowSpacing: Double {
        return spacingManager.space(.narrow)
    }
    
    var fontManager: KeasyFontManager {
        return KeasyFontManager.shared
    }
    
    var regularFont: UIFont {
        return fontManager.regularFont
    }
    
    var smallFont: UIFont {
        return fontManager.smallFont
    }
    
    var largeFont: UIFont {
        return fontManager.largeFont
    }
}

private extension KeasyKeyCell {
    func setupUI() {
        keyView = UIView(frame: .zero)
        keyView.translatesAutoresizingMaskIntoConstraints = false
        keyView.isUserInteractionEnabled = false
        contentView.addSubview(keyView)
        NSLayoutConstraint.activate(
            [
                keyView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: rowPadding / 2),
                keyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -rowPadding / 2)
            ]
        )
        
        leadingConstraint = keyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: keyPadding / 2)
        leadingConstraint.isActive = true
        trailingConstraint = keyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -keyPadding / 2)
        trailingConstraint.isActive = true
        
        iconView = UIImageView(frame: .zero)
        iconView.tintColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false
        keyView.addSubview(iconView)
        NSLayoutConstraint.activate(
            [
                iconView.centerXAnchor.constraint(equalTo: keyView.centerXAnchor),
                iconView.bottomAnchor.constraint(equalTo: keyView.bottomAnchor, constant: -narrowSpacing),
                iconView.widthAnchor.constraint(equalToConstant: 16),
                iconView.heightAnchor.constraint(equalToConstant: 16),
            ]
        )
        
        primaryLabel = UILabel(frame: .zero)
        primaryLabel.textColor = .white
        primaryLabel.font = regularFont
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        keyView.addSubview(primaryLabel)
        NSLayoutConstraint.activate(
            [
                primaryLabel.centerXAnchor.constraint(equalTo: keyView.centerXAnchor),
                primaryLabel.bottomAnchor.constraint(equalTo: keyView.bottomAnchor, constant: -2.5)
            ]
        )
        
        secondaryLabel = UILabel(frame: .zero)
        secondaryLabel.textColor = .white.withAlphaComponent(0.6)
        secondaryLabel.font = smallFont
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        keyView.addSubview(secondaryLabel)
        NSLayoutConstraint.activate(
            [
                secondaryLabel.leadingAnchor.constraint(equalTo: keyView.leadingAnchor, constant: 2),
                secondaryLabel.topAnchor.constraint(equalTo: keyView.topAnchor, constant: 1)
            ]
        )
        
        keyView.layer.cornerRadius = 5
        keyView.backgroundColor = styleManager.keyColor
        contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.001)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        contentView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(toggleAction))
        longPressGesture.minimumPressDuration = 0.2
        contentView.addGestureRecognizer(longPressGesture)
        
        tapGesture.require(toFail: longPressGesture)
        
        toggleView = UIView(frame: .zero)
        toggleView.layer.cornerRadius = 4
        toggleView.translatesAutoresizingMaskIntoConstraints = false
        toggleView.backgroundColor = .gray
        keyView.addSubview(toggleView)
        NSLayoutConstraint.activate(
            [
                toggleView.centerXAnchor.constraint(equalTo: keyView.centerXAnchor),
                toggleView.topAnchor.constraint(equalTo: keyView.topAnchor, constant: 4),
                toggleView.widthAnchor.constraint(equalToConstant: spacingManager.space(.toggleWidth)),
                toggleView.heightAnchor.constraint(equalToConstant: spacingManager.space(.toggleWidth)),
            ]
        )
    }
    
    func updateUI(viewModel: KeasyKeyPairViewModel) {
        if let icon = viewModel.primaryKey.icon {
            iconView.image = icon
            primaryLabel.text = nil
        } else {
            iconView.image = nil
            primaryLabel.text = viewModel.primaryTitle
        }
        secondaryLabel.text = viewModel.secondaryTitle
        
        
        switch viewModel.primaryKey.titleSize {
        case .regular:
            primaryLabel.font = regularFont
        case .small:
            primaryLabel.font = smallFont
        case .large:
            primaryLabel.font = largeFont
        }
        
        switch viewModel.primaryKey.key {
        case .shift:
            trailingConstraint.constant = -keyPadding
        case .delete:
            leadingConstraint.constant = keyPadding
        default:
            leadingConstraint.constant = keyPadding / 2
            trailingConstraint.constant = -keyPadding / 2
        }
    }
    
    func updateToggle(viewModel: KeasyKeyPairViewModel) {
        toggleView.isHidden = viewModel.isToggleHidden
        toggle(state: viewModel.toggleState)
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
        actionDelegate?.keyCell(self, didLongPress: viewModel)
    }
}
