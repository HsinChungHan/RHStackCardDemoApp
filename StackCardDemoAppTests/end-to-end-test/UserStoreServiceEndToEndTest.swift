//
//  UserStoreServiceEndToEndTest.swift
//  StackCardDemoAppTests
//
//  Created by Chung Han Hsin on 2025/8/25.
//

import XCTest
@testable import StackCardDemoApp

final class UserStoreServiceEndToEndTest: XCTestCase {
    
    private var sut: UserStoreService!
    
    override func setUp() {
        super.setUp()
        sut = UserStoreService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_loadAllUsers_endToEnd_returnsInsertedUsers() {
        // Arrange
        let users: [UserDTO] = [
            .init(
                name: "Jessica",
                userID: 13620229,
                age: 25,
                loc: "Ripon, CA",
                aboutMe: "baby stoner, + size \nbig boob haver and enjoyer\nlast pic is most recent :)",
                profilePicUrl: "https://down-static.s3.us-west-2.amazonaws.com/picks_filter/female_v2/pic00000.jpg"
            ),
            .init(
                name: "Krystina",
                userID: 13620230,
                age: 33,
                loc: "San Pablo, CA",
                aboutMe: "Trying to find a girl to be our 3rd. Love to be creampied. Travel between Bishop and Salinas.\n Don’t call me nicknames, I’m not your baby!",
                profilePicUrl: "https://down-static.s3.us-west-2.amazonaws.com/picks_filter/female_v2/pic00001.jpg"
            )
        ]
        
        let insertExpectation = expectation(description: "insert")
        sut.insertUsers(users: users) { result in
            switch result {
            case .success():
                insertExpectation.fulfill()
            case .failure(let err):
                XCTFail("Insertion failed: \(err)")
            }
        }
        wait(for: [insertExpectation], timeout: 2.0)
        
        // Act
        let loadExpectation = expectation(description: "load")
        var loaded: [UserDTO] = []
        sut.loadAllUsers { result in
            switch result {
            case .success(let list):
                loaded = list
                loadExpectation.fulfill()
            case .failure(let err):
                XCTFail("Load failed: \(err)")
            }
        }
        wait(for: [loadExpectation], timeout: 2.0)
        
        // Assert
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].name, "Jessica")
        XCTAssertEqual(loaded[0].userID, 13620229)
        XCTAssertEqual(loaded[0].loc, "Ripon, CA")
        XCTAssertEqual(loaded[1].name, "Krystina")
        XCTAssertEqual(loaded[1].userID, 13620230)
        XCTAssertEqual(loaded[1].age, 33)
    }
}

