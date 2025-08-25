//
//  UserUsecaseTests.swift
//  StackCardDemoAppTests
//
//  Created by Chung Han Hsin on 2025/8/26.
//

import XCTest
@testable import StackCardDemoApp

final class UserUsecaseTests: XCTestCase {

    // MARK: - Helpers

    private func makeDTOs(_ ids: [Int]) -> [UserDTO] {
        ids.map {
            UserDTO(name: "name\($0)",
                    userID: $0,
                    age: 20 + $0,
                    loc: "loc\($0)",
                    aboutMe: "about\($0)",
                    profilePicUrl: "https://example.com/\($0).png")
        }
    }

    private func makeUsecase(mockRepo: MockUserRepository,
                             deliverOnMainQueue: Bool = true) -> UserUsecase {
        UserUsecase(repo: mockRepo, deliverOnMainQueue: deliverOnMainQueue)
    }

    // MARK: - Tests

    /// Case 1: Local-first — repo emits local then remote; usecase should:
    /// - call back twice
    /// - map DTOs to domain Users
    /// - deliver on main thread
    func test_loadUsersCachedThenSync_emitsLocalThenRemote_mappedAndOnMainThread() {
        let localDTOs = makeDTOs([1, 2])
        let remoteDTOs = makeDTOs([3, 4, 5])

        let repo = MockUserRepository()
        repo.cachedThenSyncResults = [
            .success(localDTOs),
            .success(remoteDTOs)
        ]

        let sut = makeUsecase(mockRepo: repo)

        let exp = expectation(description: "expect two callbacks")
        exp.expectedFulfillmentCount = 2

        var receivedBatches: [[User]] = []
        var mainThreadFlags: [Bool] = []

        sut.loadUsersCachedThenSync { result in
            switch result {
            case let .success(users):
                receivedBatches.append(users)
                mainThreadFlags.append(Thread.isMainThread)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        let expectedLocal = User.fromDTOs(localDTOs)
        let expectedRemote = User.fromDTOs(remoteDTOs)

        XCTAssertEqual(receivedBatches.count, 2)
        XCTAssertEqual(receivedBatches[0], expectedLocal, "First callback should map local DTOs to domain Users")
        XCTAssertEqual(receivedBatches[1], expectedRemote, "Second callback should map remote DTOs to domain Users")
        XCTAssertTrue(mainThreadFlags.allSatisfy { $0 }, "Callbacks should be delivered on main thread")
    }

    /// Case 2: No local; remote success — only one callback with mapped remote users.
    func test_loadUsersCachedThenSync_whenNoLocalAndRemoteSuccess_returnsRemoteOnceMapped() {
        let remoteDTOs = makeDTOs([10])
        let repo = MockUserRepository()
        repo.cachedThenSyncResults = [.success(remoteDTOs)]

        let sut = makeUsecase(mockRepo: repo)

        let exp = expectation(description: "expect one callback")
        var received: [User]?

        sut.loadUsersCachedThenSync { result in
            if case let .success(users) = result {
                received = users
            } else {
                XCTFail("Unexpected failure")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(received, User.fromDTOs(remoteDTOs))
    }

    /// Case 3: Failure mapping — repo fails; usecase should map to UserUsecaseError.
    func test_loadUsersCachedThenSync_whenRepoFails_mapsError() {
        let repo = MockUserRepository()
        repo.cachedThenSyncResults = [.failure(.network)]

        let sut = makeUsecase(mockRepo: repo)

        let exp = expectation(description: "expect failure")
        var receivedError: UserUsecaseError?

        sut.loadUsersCachedThenSync { result in
            if case let .failure(err) = result {
                receivedError = err
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError, .network)
    }

    /// Case 4: refreshUsers success — maps DTOs and delivers on main.
    func test_refreshUsers_success_mapsAndOnMainThread() {
        let remoteDTOs = makeDTOs([42, 43])

        let repo = MockUserRepository()
        repo.refreshResult = .success(remoteDTOs)

        let sut = makeUsecase(mockRepo: repo)

        let exp = expectation(description: "expect success")
        var received: [User]?
        var isMain: Bool?

        sut.refreshUsers { result in
            switch result {
            case let .success(users):
                received = users
                isMain = Thread.isMainThread
            case .failure:
                XCTFail("Unexpected failure")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(received, User.fromDTOs(remoteDTOs))
        XCTAssertEqual(isMain, true)
    }

    /// Case 5: refreshUsers failure — error mapping verified.
    func test_refreshUsers_failure_mapsError() {
        let repo = MockUserRepository()
        repo.refreshResult = .failure(.store)

        let sut = makeUsecase(mockRepo: repo)

        let exp = expectation(description: "expect failure")
        var receivedError: UserUsecaseError?

        sut.refreshUsers { result in
            if case let .failure(err) = result {
                receivedError = err
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError, .store)
    }
}
