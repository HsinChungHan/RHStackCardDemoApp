//
//  MockUserRepository.swift
//  StackCardDemoAppTests
//
//  Created by Chung Han Hsin on 2025/8/26.
//

import Foundation
@testable import StackCardDemoApp

/// A configurable mock for UserRepositoryProtocol.
final class MockUserRepository: UserRepositoryProtocol {

    /// Sequence of results to emit for getUsersCachedThenSync (supports local-then-remote).
    var cachedThenSyncResults: [Result<[UserDTO], UserRepositoryError>] = [.success([])]

    /// Single result for refreshUsers.
    var refreshResult: Result<[UserDTO], UserRepositoryError> = .success([])

    // MARK: - Protocol

    func getUsersCachedThenSync(_ completion: @escaping (Result<[UserDTO], UserRepositoryError>) -> Void) {
        // Emit each configured result in order (e.g., local then remote)
        for result in cachedThenSyncResults {
            completion(result)
        }
    }

    func refreshUsers(_ completion: @escaping (Result<[UserDTO], UserRepositoryError>) -> Void) {
        completion(refreshResult)
    }
}

