//
//  UserUsecase.swift
//  StackCardDemoApp
//
//  Created by Chung Han Hsin on 2025/8/26.
//

import Foundation

// MARK: - Usecase Error
enum UserUsecaseError: Error {
    case network
    case decode
    case store
    case unknown
}

// MARK: - Protocol
protocol UserUsecaseProtocol {
    /// Local-first: returns cached Users first (if any), then returns fresh remote users.
    func loadUsersCachedThenSync(_ completion: @escaping (Result<[User], UserUsecaseError>) -> Void)

    /// Force refresh from remote and overwrite cache.
    func refreshUsers(_ completion: @escaping (Result<[User], UserUsecaseError>) -> Void)
}

// MARK: - Implementation
final class UserUsecase: UserUsecaseProtocol {

    private let repo: UserRepositoryProtocol
    /// Ensure UI-friendly callbacks on main thread.
    private let deliverOnMainQueue: Bool

    init(repo: UserRepositoryProtocol, deliverOnMainQueue: Bool = true) {
        self.repo = repo
        self.deliverOnMainQueue = deliverOnMainQueue
    }

    func loadUsersCachedThenSync(_ completion: @escaping (Result<[User], UserUsecaseError>) -> Void) {
        repo.getUsersCachedThenSync { [weak self] result in
            self?.forward(result.map(User.fromDTOs), to: completion)
        }
    }

    func refreshUsers(_ completion: @escaping (Result<[User], UserUsecaseError>) -> Void) {
        repo.refreshUsers { [weak self] result in
            self?.forward(result.map(User.fromDTOs), to: completion)
        }
    }
}

// MARK: - Private helpers
private extension UserUsecase {
    static func mapError(_ error: UserRepositoryError) -> UserUsecaseError {
        switch error {
        case .network: return .network
        case .decode:  return .decode
        case .store:   return .store
        }
    }

    func forward<T>(_ result: Result<T, UserRepositoryError>,
                            to completion: @escaping (Result<T, UserUsecaseError>) -> Void) {
        let mapped: Result<T, UserUsecaseError> = result.mapError { Self.mapError($0) }
        if deliverOnMainQueue {
            if Thread.isMainThread {
                completion(mapped)
            } else {
                DispatchQueue.main.async { completion(mapped) }
            }
        } else {
            completion(mapped)
        }
    }
}
