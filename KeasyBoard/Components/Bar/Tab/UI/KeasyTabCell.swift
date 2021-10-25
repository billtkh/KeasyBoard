//
//  KeasyTabCell.swift
//  KeasyBoardExtension
//
//  Created by Bill Tsang on 7/10/2021.
//

import Foundation
import UIKit

protocol KeasyTabCellActionDelegate: AnyObject {
    func tabCell(_ tabCell: KeasyTabCell, didTap tab: KeasyTabViewModel)
    func tabCell(_ tabCell: KeasyTabCell, didLongPress tab: KeasyTabViewModel)
}

class KeasyTabCell: UICollectionViewCell {
    weak var actionDelegate: KeasyTabCellActionDelegate?
    var viewModel: KeasyTabViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            updateUI(viewModel: viewModel)
        }
    }
    
    private var tabView: UIView!
    
    private var iconView: UIImageView!
    
    private var titleLabel: UILabel!
    
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

private extension KeasyTabCell {
    var styleManager: KeasyStyleManager {
        return KeasyStyleManager.shared
    }
    
    var spacingManager: KeasySpacingManager {
        return KeasySpacingManager.shared
    }
    
    var horizontalPadding: Double {
        return spacingManager.space(.barHorizontalPadding)
    }
    
    var verticalPadding: Double {
        return spacingManager.space(.barVerticalPadding)
    }
    
    var narrowSpacing: Double {
        return spacingManager.space(.narrow)
    }
    
    var commonSpacing: Double {
        return spacingManager.space(.common)
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

private extension KeasyTabCell {
    func setupUI() {
        tabView = UIView(frame: .zero)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tabView)
        NSLayoutConstraint.activate(
            [
                tabView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding / 2),
                tabView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalPadding / 2)
            ]
        )
        
        leadingConstraint = tabView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding / 2)
        leadingConstraint.isActive = true
        trailingConstraint = tabView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding / 2)
        trailingConstraint.isActive = true
        
        iconView = UIImageView(frame: .zero)
        iconView.tintColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false
        tabView.addSubview(iconView)
        NSLayoutConstraint.activate(
            [
                iconView.centerXAnchor.constraint(equalTo: tabView.centerXAnchor),
                iconView.bottomAnchor.constraint(equalTo: tabView.bottomAnchor, constant: -narrowSpacing),
                iconView.widthAnchor.constraint(equalToConstant: 12),
                iconView.heightAnchor.constraint(equalToConstant: 12),
            ]
        )
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = .white
        titleLabel.font = regularFont
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tabView.addSubview(titleLabel)
        NSLayoutConstraint.activate(
            [
                titleLabel.centerXAnchor.constraint(equalTo: tabView.centerXAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: tabView.bottomAnchor, constant: -2.5)
            ]
        )

        tabView.layer.cornerRadius = 5
        tabView.backgroundColor = styleManager.keyColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        contentView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(toggleAction))
        longPressGesture.minimumPressDuration = 0.6
        contentView.addGestureRecognizer(longPressGesture)
        
        tapGesture.require(toFail: longPressGesture)
    }
    
    func updateUI(viewModel: KeasyTabViewModel) {
        if let icon = viewModel.icon {
            iconView.image = icon
            titleLabel.text = nil
        } else {
            iconView.image = nil
            titleLabel.text = viewModel.title
        }
        
        titleLabel.font = viewModel.titleFont
    }
    
    @objc
    func tapAction() {
        guard let viewModel = viewModel else { return }
        actionDelegate?.tabCell(self, didTap: viewModel)
    }
    
    @objc
    func toggleAction(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        guard let viewModel = viewModel else { return }
        actionDelegate?.tabCell(self, didLongPress: viewModel)
    }
}
