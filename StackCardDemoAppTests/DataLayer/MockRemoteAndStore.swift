//
//  MockRemoteAndStore.swift
//  StackCardDemoAppTests
//
//  Created by Chung Han Hsin on 2025/8/26.
//

import Foundation
@testable import StackCardDemoApp

// MARK: - Mock Remote

final class MockUserRemoteService: UserRemoteServiceProtocol {
    var loadAllUsersResult: Result<[UserDTO], UserRemoteServiceError> = .success([])
    var downloadUserImageResult: Result<Data, UserRemoteServiceError> = .failure(.networkError)

    func loadAllUsers(completion: @escaping (Result<[UserDTO], UserRemoteServiceError>) -> Void) {
        completion(loadAllUsersResult)
    }

    func downloadUserImage(with id: String, completion: @escaping (Result<Data, UserRemoteServiceError>) -> Void) {
        completion(downloadUserImageResult)
    }
}

// MARK: - Mock Store

final class MockUserStoreService: UserStoreServiceProtocol {
    // 控制讀寫行為
    var loadAllUsersResult: Result<[UserDTO], UserStoreServiceError> = .success([])
    var insertUsersResult: Result<Void, UserStoreServiceError> = .success(())

    // 記錄被落地的內容以便驗證
    private(set) var lastInsertedUsers: [UserDTO] = []

    func loadAllUsers(completion: @escaping (Result<[UserDTO], UserStoreServiceError>) -> Void) {
        completion(loadAllUsersResult)
    }

    func insertUsers(with json: [String : Any], completion: @escaping (Result<Void, UserStoreServiceError>) -> Void) {
        completion(insertUsersResult)
    }

    func insertUsers(users: [UserDTO], completion: @escaping (Result<Void, UserStoreServiceError>) -> Void) {
        lastInsertedUsers = users
        completion(insertUsersResult)
    }
}

