//
//  Card.swift
//  StackCardDemoApp
//
//  Created by Chung Han Hsin on 2025/8/26.
//

import Foundation
import RHStackCard

struct UserCard: Card {
    var uid: String
    var imageURLs: [URL]
    var cardViewTypeName: String = ""
    let imageNames: [String] = []
    
    let name: String
    let age: Int
    let location: String
    let about: String
    
    init(id: Int, name: String, age: Int, location: String, about: String, profilePicURL: URL?, cardViewTypeName: String) {
        uid = "\(id)"
        let urls = profilePicURL.map { [$0] } ?? []
        self.imageURLs = UserCard.normalizeImageURLs(urls)
        self.cardViewTypeName = cardViewTypeName
        
        self.name = name
        self.age = age
        self.location = location
        self.about = about
    }
    
    init(user: User, cardViewTypeName: String) {
        uid = "\(user.id)"
        let urls = user.profilePicURL.map { [$0] } ?? []
        self.imageURLs = UserCard.normalizeImageURLs(urls)
        self.name = user.name
        self.age = user.age
        self.location = user.location
        self.about = user.about
        self.cardViewTypeName = cardViewTypeName
    }
    
    static func fromUsers(_ users: [User], cardViewTypeName: String) -> [UserCard] {
        users.map { UserCard(user: $0, cardViewTypeName: cardViewTypeName) }
    }
    
    // MARK: - Helpers
    
    /// If there's only 1 URL, replicate it to 3 copies. Otherwise return as is.
    private static func normalizeImageURLs(_ urls: [URL]) -> [URL] {
        if urls.count == 1 {
            return Array(repeating: urls[0], count: 3)
        } else {
            return urls
        }
    }
}

