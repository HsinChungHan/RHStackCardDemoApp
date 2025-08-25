//
//  User.swift
//  StackCardDemoApp
//
//  Created by Chung Han Hsin on 2025/8/26.
//

import Foundation

// domain model
struct User: Equatable {
     let id: Int
     let name: String
     let age: Int
     let location: String
     let about: String
     let profilePicURL: URL?

     init(id: Int, name: String, age: Int, location: String, about: String, profilePicURL: URL?) {
        self.id = id
        self.name = name
        self.age = age
        self.location = location
        self.about = about
        self.profilePicURL = profilePicURL
    }

    /// Convenience initializer to map from UserDTO
     init(dto: UserDTO) {
        self.id = dto.userID
        self.name = dto.name
        self.age = dto.age
        self.location = dto.loc
        self.about = dto.aboutMe
        self.profilePicURL = URL(string: dto.profilePicUrl)
    }

    /// Bulk conversion helper
     static func fromDTOs(_ dtos: [UserDTO]) -> [User] {
        return dtos.map { User(dto: $0) }
    }
}
