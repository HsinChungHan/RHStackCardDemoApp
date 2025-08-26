//
//  UserPageViewModel.swift
//  StackCardDemoApp
//
//  Created by Chung Han Hsin on 2025/8/26.
//

import Foundation
import RHStackCard
import UIKit

// MARK: - UI State
enum UserPageState: Equatable {
    case idle
    case loading        // first-time loading (may not have local cache yet)
    case refreshing     // pull-to-refresh or explicit refresh
    case loaded         // has data
    case empty          // no data
    case error(String)  // displayable error message
}

// MARK: - Delegate
protocol UserPageViewModelDelegate: AnyObject {
    func userVM(_ vm: UserPageViewModel, didChangeState state: UserPageState)
    func userVM(_ vm: UserPageViewModel, didUpdateCards cards: [UserCard])
}

final class UserPageViewModel {
    private(set) var userCards: [UserCard] = []
    private(set) var state: UserPageState = .idle {
        didSet { notifyState() }
    }

    private let usecase: UserUsecaseProtocol
    weak var delegate: UserPageViewModelDelegate?
    
    private let cardViewTypeName = "UserCardView"

    // Track whether the local cache has already been emitted
    private var didReceiveFirstBatch = false
    
    lazy var stackCardService = RHStackCardInterface()
    
    init(usecase: UserUsecaseProtocol) {
        self.usecase = usecase
    }

    // MARK: - Interval APIs
    // Corresponds to UIViewController.viewDidLoad / viewWillAppear
    func viewDidLoad() {
        state = .loading
        didReceiveFirstBatch = false

        usecase.loadUsersCachedThenSync { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(users):
                self.didReceiveFirstBatch = true
                self.userCards = UserCard.fromUsers(users, cardViewTypeName: cardViewTypeName)
                self.notifyUsers()
                self.state = users.isEmpty ? .empty : .loaded

            case let .failure(error):
                // Only show error if no local cache has been emitted; otherwise keep the current state
                guard self.didReceiveFirstBatch == false else { return }
                self.state = .error(self.message(for: error))
            }
        }
    }
    
    var cardDeskView: UIView { stackCardService.cardDeskViewController?.view ?? UIView() }
    
    func setupDeskCardView() -> CardDeskViewController {
        let cardDeskViewController = stackCardService.setup(dataSource: self, delegate: self)
        stackCardService.registerCustomCardView(cardViewID: cardViewTypeName, cardViewType: UserCardView.self)
        return cardDeskViewController
    }
    
    func addUserCards() {
        stackCardService.addNewCards()
    }
}

// MARK: - Private helpers
private extension UserPageViewModel {
    func notifyUsers() {
        // Ensure callbacks on the main thread (Usecase already guarantees this, but just in case)
        if Thread.isMainThread {
            delegate?.userVM(self, didUpdateCards: userCards)
        } else {
            DispatchQueue.main.async { [userCards, weak self] in
                guard let self = self else { return }
                self.delegate?.userVM(self, didUpdateCards: userCards)
            }
        }
    }

    func notifyState() {
        if Thread.isMainThread {
            delegate?.userVM(self, didChangeState: state)
        } else {
            let newState = state
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.userVM(self, didChangeState: newState)
            }
        }
    }

    func message(for error: UserUsecaseError) -> String {
        switch error {
        case .network: return "Network error. Please try again."
        case .decode:  return "Data parsing error."
        case .store:   return "Local cache error."
        case .unknown: return "Unknown error."
        }
    }
}

// MARK: - CardDeskViewControllerDataSource
extension UserPageViewModel: CardDeskViewControllerDataSource {
    var cards: [RHStackCard.Card] { userCards }
    var domainURL: URL? { .init(string: "https://down-static.s3.us-west-2.amazonaws.com") }
}

// MARK: - CardDeskViewControllerDelegate
extension UserPageViewModel: CardDeskViewControllerDelegate {
    func cardDeskViewController(_ cardDeskVC: RHStackCard.CardDeskViewController, didReciveCardViewSlidingEvent event: RHStackCard.ObservableEvents.CardViewEvents.SlidingEvent) {}
    
    func cardDeskViewController(_ cardDeskVC: RHStackCard.CardDeskViewController, willPerformCardViewAction direction: RHStackCard.SlidingDirection) {}
    
    func cardDeskViewController(_ cardDeskVC: RHStackCard.CardDeskViewController, didPerformCardViewAction direction: RHStackCard.SlidingDirection) {
        switch direction {
        case .toLeft:
            print("User dislikes this card")
        case .toRight:
            print("User likes this card")
        case .toTop:
            print("User superlike this card")
        default:
            break
        }
    }
}
