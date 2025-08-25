//
//  UserDTO.swift
//  StackCardDemoApp
//
//  Created by Chung Han Hsin on 2025/8/25.
//

import Foundation
/*
    "name": "Krystina",
    "user_id": 13620230,
    "age": 33,
    "loc": "San Pablo, CA",
    "about_me": "Trying to find a girl to be our 3rd. Love to be creampied. Travel between Bishop and Salinas.\n Don’t call me nicknames, I’m not your baby!",
    "profile_pic_url": "https://down-static.s3.us-west-2.amazonaws.com/picks_filter/female_v2/pic00001.jpg",
 */

struct UserDTO: Codable  {
    let name: String
    let userID: Int
    let age: Int
    let loc: String
    let aboutMe: String
    let profilePicUrl: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case userID = "user_id"
        case age
        case loc
        case aboutMe = "about_me"
        case profilePicUrl = "profile_pic_url"
    }
    
}
