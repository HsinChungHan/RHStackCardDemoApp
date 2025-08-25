//
//  UserRepositoryTests.swift
//  StackCardDemoAppTests
//
//  Created by Chung Han Hsin on 2025/8/26.
//

import XCTest
@testable import StackCardDemoApp

final class UserRepositoryTests: XCTestCase {

    // MARK: - Helpers

    private func makeSUT(
        remoteResult: Result<[UserDTO], UserRemoteServiceError>,
        storeLoadResult: Result<[UserDTO], UserStoreServiceError>,
        storeInsertResult: Result<Void, UserStoreServiceError> = .success(())
    ) -> (UserRepository, MockUserRemoteService, MockUserStoreService) {

        let remote = MockUserRemoteService()
        remote.loadAllUsersResult = remoteResult

        let store = MockUserStoreService()
        store.loadAllUsersResult = storeLoadResult
        store.insertUsersResult = storeInsertResult

        let sut = UserRepository(remote: remote, store: store)
        return (sut, remote, store)
    }

    private func users(_ ids: [Int]) -> [UserDTO] {
        ids.map { UserDTO(name: "", userID: $0, age: -1, loc: "", aboutMe: "", profilePicUrl: "") }
    }

    // MARK: - Tests

    /// Case 1: Local-first
    /// Store has data → return local first; remote succeeds → return remote afterwards
    func test_getUsersCachedThenSync_returnsLocalThenRemote() {
        let local = users([1, 2])
        let remote = users([3, 4, 5])

        let (sut, _, store) = makeSUT(
            remoteResult: .success(remote),
            storeLoadResult: .success(local)
        )

        let exp = expectation(description: "expect two callbacks")
        exp.expectedFulfillmentCount = 2

        var received: [[UserDTO]] = []

        sut.getUsersCachedThenSync { result in
            switch result {
            case let .success(list):
                received.append(list)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(received.count, 2)
        XCTAssertEqual(received[0], local, "First callback should be local cache")
        XCTAssertEqual(received[1], remote, "Second callback should be fresh remote")
        XCTAssertEqual(store.lastInsertedUsers, remote, "Remote success should be persisted")
    }

    /// Case 2: No local data, remote succeeds → return remote once
    func test_getUsersCachedThenSync_whenNoLocalAndRemoteSuccess_returnsRemoteOnce() {
        let remote = users([10])

        let (sut, _, store) = makeSUT(
            remoteResult: .success(remote),
            storeLoadResult: .success([])
        )

        let exp = expectation(description: "expect one callback")

        var received: [UserDTO]?
        sut.getUsersCachedThenSync { result in
            if case let .success(list) = result {
                received = list
            } else {
                XCTFail("Unexpected error")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(received, remote)
        XCTAssertEqual(store.lastInsertedUsers, remote)
    }

    /// Case 3: No local data, remote fails → return error
    func test_getUsersCachedThenSync_whenNoLocalAndRemoteFails_returnsError() {
        let (sut, _, _) = makeSUT(
            remoteResult: .failure(.networkError),
            storeLoadResult: .success([])
        )

        let exp = expectation(description: "expect failure")
        var receivedError: UserRepositoryError?

        sut.getUsersCachedThenSync { result in
            if case let .failure(err) = result {
                receivedError = err
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError, .network)
    }

    /// Case 4: Local data exists, remote fails → should only return local (no error override)
    func test_getUsersCachedThenSync_whenLocalExistsAndRemoteFails_returnsOnlyLocal() {
        let local = users([7, 8, 9])

        let (sut, _, store) = makeSUT(
            remoteResult: .failure(.networkError),
            storeLoadResult: .success(local)
        )

        let exp = expectation(description: "expect one callback (local only)")

        var received: [UserDTO]?
        var callbackCount = 0

        sut.getUsersCachedThenSync { result in
            callbackCount += 1
            switch result {
            case let .success(list): received = list
            case .failure: XCTFail("Should not return error when local already emitted")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(callbackCount, 1, "Should only emit once")
        XCTAssertEqual(received, local)
        XCTAssertTrue(store.lastInsertedUsers.isEmpty, "Remote failed, no new persist")
    }

    /// Case 5: refreshUsers remote succeeds but store insert fails → should still return remote data as success
    func test_refreshUsers_persistsButInsertFails_stillReturnsRemoteSuccess() {
        let remote = users([42])

        let (sut, _, store) = makeSUT(
            remoteResult: .success(remote),
            storeLoadResult: .success([]),
            storeInsertResult: .failure(.failureInsertion)
        )

        let exp = expectation(description: "expect success even if persist fails")
        var received: [UserDTO]?

        sut.refreshUsers { result in
            if case let .success(list) = result {
                received = list
            } else {
                XCTFail("unexpected failure")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(received, remote)
        XCTAssertEqual(store.lastInsertedUsers, remote, "Repo still attempted to persist, but failure is allowed")
    }
}
