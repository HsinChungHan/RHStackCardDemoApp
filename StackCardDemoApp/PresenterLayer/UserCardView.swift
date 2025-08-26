//
//  UserCardView.swift
//  StackCardDemoApp
//
//  Created by Chung Han Hsin on 2025/8/26.
//

import Foundation
import RHStackCard
import RHUIComponent
import UIKit

final class UserCardView: CardView {
    let cardViewControlBarSafeAreaInset: CGFloat = 64
    
    var _card: UserCard {
        guard let card = card as? UserCard else { fatalError() }
        return card
    }
    
    // MARK: - Labels
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = _card.name
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 28)
        return label
    }()
    
    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.text = "Age: \(_card.age)"
        label.textColor = .white.withAlphaComponent(0.85)
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = _card.location
        label.textColor = .white.withAlphaComponent(0.85)
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var aboutLabel: UILabel = {
        let label = UILabel()
        label.text = _card.about
        label.textColor = .white
        label.font = .italicSystemFont(ofSize: 16)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    // A vertical stack for info labels
    private lazy var infoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, ageLocationStack, aboutLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()
    
    // Horizontal stack for age + location
    private lazy var ageLocationStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ageLabel, locationLabel])
        stack.axis = .horizontal
        stack.spacing = 16
        return stack
    }()
    
    // MARK: - Button
    lazy var goToDetailVCButton = makeGoToDetailVCButton()
    
    // MARK: - Layout
    override func setupLayout() {
        super.setupLayout()
        uidLabel.removeFromSuperview()
        
        addSubview(infoStack)
        infoStack.constraint(
            bottom: snp.bottom,
            leading: snp.leading,
            trailing: snp.trailing,
            padding: .init(top: 0, left: 16, bottom: cardViewControlBarSafeAreaInset + 60, right: 16)
        )
        
        addSubview(goToDetailVCButton)
        goToDetailVCButton.constraint(
            bottom: snp.bottom,
            trailing: snp.trailing,
            padding: .init(top: 0, left: 0, bottom: cardViewControlBarSafeAreaInset + 8, right: 16),
            size: .init(width: 44, height: 44)
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        goToDetailVCButton.layer.cornerRadius = 22
        goToDetailVCButton.clipsToBounds = true
    }
    
    func makeGoToDetailVCButton() -> UIButton {
        let view = UIButton()
        view.backgroundColor = Color.Neutral.v0.withAlphaComponent(0.8)
        view.setImage(UIImage(named: "detail"), for: .normal)
        view.tintColor = .white
        view.addTarget(self, action: #selector(handleGoToDetailVCButton), for: .touchUpInside)
        return view
    }
    
    @objc func handleGoToDetailVCButton(_ sender: UIButton) {
        // TODO: handle navigation
    }
}
