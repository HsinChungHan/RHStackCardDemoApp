//
//  UserStoreService.swift
//  StackCardDemoApp
//
//  Created by Chung Han Hsin on 2025/8/25.
//

import Foundation
import RHCacheStoreAPI

enum UserStoreServiceError: Error {
    case failureInsertion
    case failureLoad
    case failureDeletion
}


protocol UserStoreServiceProtocol {
    func loadAllUsers(completion: @escaping (Result<[UserDTO], UserStoreServiceError>) -> Void)
    func insertUsers(with json: [String: Any], completion: @escaping (Result<Void, UserStoreServiceError>) -> Void)
    func insertUsers(users: [UserDTO], completion: @escaping (Result<Void, UserStoreServiceError>) -> Void)
}

final class UserStoreService: UserStoreServiceProtocol {
    private let factory = RHCacheStoreAPIImplementationFactory()
    private let store: RHActorCacheStoreAPIProtocol
    private let field = "users"
    init() {
        let allUsersStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("allUsers.json")
        
        store = factory.makeActorCodableStore(with: allUsersStoreURL)
    }
    
    func loadAllUsers(completion: @escaping (Result<[UserDTO], UserStoreServiceError>) -> Void) {
        Task {
            let result = await store.retrieve(with: field)
            switch result {
            case let .found(jsonAny):
                // 期望是 ["items": [[String: Any]]]
                if let dict = jsonAny as? [String: Any],
                   let items = dict["items"] as? [[String: Any]],
                   let userDTOs: [UserDTO] = JSONDecoder().toCodableArray(from: items) {
                    completion(.success(userDTOs))
                } else {
                    completion(.failure(.failureLoad))
                }
            default:
                completion(.failure(.failureLoad))
            }
        }
    }
    
    func insertUsers(with json: [String: Any], completion: @escaping (Result<Void, UserStoreServiceError>) -> Void) {
        Task {
            do {
               try await store.insert(with: field, json: json)
                completion(.success(()))
            } catch {
                completion(.failure(.failureInsertion))
            }
        }
    }
    
    func insertUsers(users: [UserDTO], completion: @escaping (Result<Void, UserStoreServiceError>) -> Void) {
            Task {
                // 將 [UserDTO] -> [[String: Any]] -> 包成 ["items": ...]
                guard let items: [[String: Any]] = JSONEncoder().toJsonArray(from: users) else {
                    completion(.failure(.failureInsertion))
                    return
                }
                do {
                    try await store.insert(with: field, json: ["items": items])
                    completion(.success(()))
                } catch {
                    completion(.failure(.failureInsertion))
                }
            }
        }
}

extension JSONDecoder {
    func toCodableObject<T: Codable>(from json: [String: Any]) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else { return nil }
        return try? decode(T.self, from: data)
    }
    
    func toCodableArray<T: Codable>(from jsonArray: [[String: Any]]) -> [T]? {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonArray, options: []) else { return nil }
        return try? decode([T].self, from: data)
    }
}

extension JSONEncoder {
    func toJson<T: Codable>(from object: T) -> [String: Any]? {
        guard let data = try? encode(object),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return json
    }
    
    func toJsonArray<T: Codable>(from objects: [T]) -> [[String: Any]]? {
        guard let data = try? encode(objects),
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { return nil }
        return json
    }
}
