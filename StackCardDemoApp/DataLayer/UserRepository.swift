//
//  UserRepository.swift
//  StackCardDemoApp
//
//  Created by Chung Han Hsin on 2025/8/26.
//

import Foundation

enum UserRepositoryError: Error {
    case decode
    case network
    case store
}

protocol UserRepositoryProtocol {
    /// Local-first: Return cached data first (if available), then refresh from remote in the background;
    /// if new remote data arrives, completion will be called again.
    func getUsersCachedThenSync(_ completion: @escaping (Result<[UserDTO], UserRepositoryError>) -> Void)

    /// Force refresh: directly fetch from remote and overwrite the cache.
    func refreshUsers(_ completion: @escaping (Result<[UserDTO], UserRepositoryError>) -> Void)
}

final class UserRepository: UserRepositoryProtocol {

    private let remote: UserRemoteServiceProtocol
    private let store: UserStoreServiceProtocol

    /// Serialize repository internal writes to avoid concurrent cache overwrites.
    private let queue = DispatchQueue(label: "com.example.userrepo")

    init(remote: UserRemoteServiceProtocol = UserRemoteService(),
         store: UserStoreServiceProtocol = UserStoreService()) {
        self.remote = remote
        self.store = store
    }

    // MARK: - Public
    func getUsersCachedThenSync(_ completion: @escaping (Result<[UserDTO], UserRepositoryError>) -> Void) {
        store.loadAllUsers { [weak self] storeResult in
            guard let self else { return }

            var didEmitLocal = false
            
            // 1) Try to load from local store first
            switch storeResult {
            case let .success(localUsers):
                if !localUsers.isEmpty {
                    didEmitLocal = true
                    completion(.success(localUsers))
                }
            case .failure:
                break
            }

            // 2) Refresh from remote in the background
            self.fetchRemoteAndPersist { remoteResult in
                switch remoteResult {
                case let .success(remoteUsers):
                    completion(.success(remoteUsers))
                case let .failure(err):
                    if !didEmitLocal {
                        completion(.failure(err))
                    }
                }
            }
        }
    }

    func refreshUsers(_ completion: @escaping (Result<[UserDTO], UserRepositoryError>) -> Void) {
        fetchRemoteAndPersist(completion)
    }

    // MARK: - Private

    private func fetchRemoteAndPersist(_ completion: @escaping (Result<[UserDTO], UserRepositoryError>) -> Void) {
        remote.loadAllUsers { [weak self] remoteResult in
            guard let self else { return }
            switch remoteResult {
            case let .success(users):
                // Persist into local cache
                self.queue.async {
                    self.store.insertUsers(users: users) { storeResult in
                        switch storeResult {
                        case .success:
                            completion(.success(users))
                        case .failure:
                            // Even if persisting fails, still return the fetched data
                            completion(.success(users))
                        }
                    }
                }
            case .failure:
                completion(.failure(.network))
            }
        }
    }
}
