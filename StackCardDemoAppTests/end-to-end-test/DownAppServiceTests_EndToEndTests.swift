//
//  DownAppServiceTests_EndToEndTests.swift
//  StackCardDemoAppTests
//
//  Created by Chung Han Hsin on 2025/8/25.
//

import XCTest
@testable import StackCardDemoApp

class DownAppServiceTests_EndToEndTests: XCTestCase {
    func test_getAllUsers_onSuccess() {
        let sut = UserRemoteService.init()
        let exp = expectation(description: "Wait for completion...")
        sut.loadAllUsers { result in
            switch result {
            case let .success(userDTOs):
                XCTAssertEqual(userDTOs.count, 10)
            default:
                XCTFail("🚨 Expected get [UserDTO] successfully, but get failed instead!")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 30.0)
    }
    
    func test_downloadUserImage_onSuccess() {
        let sut = UserRemoteService.init()
        let exp = expectation(description: "Wait for completion...")
        sut.downloadUserImage(with: "pic00001") { result in
            switch result {
            case let .success(data):
                print(data)
            default:
                XCTFail("🚨 Expected get user's image successfully, but get failed instead!")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 30.0)
    }
}

