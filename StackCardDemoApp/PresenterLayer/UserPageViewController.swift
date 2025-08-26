//
//  UserPageViewController.swift
//  StackCardDemoApp
//
//  Created by Chung Han Hsin on 2025/8/25.
//

import RHUIComponent
import RHStackCard
import SnapKit
import UIKit

class UserPageViewController: UIViewController {
    private var cardDeskView: UIView { viewModel.cardDeskView }
    private lazy var viewModel = makeUserPageViewMdoel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDeskCardView()
        viewModel.viewDidLoad()
    }
}

// MARK: - Private helpers
extension UserPageViewController {
    func makeUserPageViewMdoel() -> UserPageViewModel {
        let repo = UserRepository()
        let usecase = UserUsecase(repo: repo)
        let viewModel = UserPageViewModel(usecase: usecase)
        viewModel.delegate = self
        return viewModel
    }
    
    func setupDeskCardView() {
        let cardDeskViewController = viewModel.setupDeskCardView()
        addChild(cardDeskViewController)
        view.addSubview(cardDeskViewController.view)
        
        let cardWidth = UIScreen.main.bounds.width - 96
        cardDeskViewController.view.constraint(
            centerX: view.snp.centerX,
            centerY: view.snp.centerY,
            padding: .init(top: 32, left: 0, bottom: 0, right: 0),
            size: .init(width: cardWidth, height: cardWidth * 16 / 9)
        )
        cardDeskViewController.didMove(toParent: self)
    }
}

extension UserPageViewController: UserPageViewModelDelegate {
    func userVM(_ vm: UserPageViewModel, didChangeState state: UserPageState) {
        // TODO: - Toggle the loading indicator based on state
    }
    
    func userVM(_ vm: UserPageViewModel, didUpdateCards cards: [UserCard]) {
        vm.addUserCards()
    }
}
