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
    lazy var stackCardService = RHStackCardInterface()
    var cardDeskView: UIView { viewModel.cardDeskView }
    lazy var viewModel = makeUserPageViewMdoel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }
}

extension UserPageViewController {
    func makeUserPageViewMdoel() -> UserPageViewModel {
        let repo = UserRepository()
        let usecase = UserUsecase(repo: repo)
        let viewModel = UserPageViewModel(usecase: usecase)
        viewModel.delegate = self
        return viewModel
    }
}

extension UserPageViewController: UserPageViewModelDelegate {
    func userVM(_ vm: UserPageViewModel, didChangeState state: UserPageState) {
    }
    
    func userVM(_ vm: UserPageViewModel, didUpdateCards cards: [UserCard]) {
        
        let alreadyHasDeskVC = children.contains { $0 is CardDeskViewController }
        guard !alreadyHasDeskVC else { return }
        // create and add card desk VC
        // TODO: - Add refresh method to RHStackCard framework
        let cardDeskViewController = vm.setupDeskCardView()
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
