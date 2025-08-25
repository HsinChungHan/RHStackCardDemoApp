//
//  UserRemoteService.swift
//  StackCardDemoApp
//
//  Created by Chung Han Hsin on 2025/8/25.
//

import Foundation
import RHNetworkAPI

enum UserRemoteServiceError: Error {
    case jsonError
    case networkError
}

protocol UserRemoteServiceProtocol {
    func loadAllUsers(completion: @escaping (Result<[UserDTO], UserRemoteServiceError>) -> Void)
    func downloadUserImage(with id: String, completion: @escaping (Result<Data, UserRemoteServiceError>) -> Void)
}

final class UserRemoteService: UserRemoteServiceProtocol {
    private let factory = RHNetworkAPIImplementationFactory()
    private let dataNetworkAPI: RHNetworkAPIProtocol
    private let imageNetworkAPI: RHNetworkAPIProtocol
    private let userAPIDomainUrl = "https://raw.githubusercontent.com"
    private let mediaDomainUrl = "https://down-static.s3.us-west-2.amazonaws.com"
    
    init() {
        dataNetworkAPI = factory.makeNonCacheAndNoneUploadProgressClient(with: .init(string: userAPIDomainUrl)!)
        
        let headers: [String : String] =
            [
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
            ]
        
        // "profile_pic_url": "https://down-static.s3.us-west-2.amazonaws.com/picks_filter/female_v2/pic00001.jpg"
        imageNetworkAPI = factory.makeNonCacheAndNoneUploadProgressClient(with: .init(string: mediaDomainUrl)!, headers: headers)
    }
    
    // https://raw.githubusercontent.com/downapp/sample/main/sample.json
    func loadAllUsers(completion: @escaping (Result<[UserDTO], UserRemoteServiceError>) -> Void) {
        let path = "/downapp/sample/main/sample.json"
        let queries: [URLQueryItem] = []
        dataNetworkAPI.get(path: path, queryItems: queries) { result in
            switch result {
            case let .success(data, _):
                do {
                    let userDTOs = try JSONDecoder().decode([UserDTO].self, from: data)
                    completion(.success(userDTOs))
                } catch {
                    completion(.failure(.jsonError))
                }
            case .failure(_):
                completion(.failure(.networkError))
            }
        }
    }
    
    func downloadUserImage(with id: String, completion: @escaping (Result<Data, UserRemoteServiceError>) -> Void) {
        
    }
}
