//
//  SCAuthManager.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import Foundation

class SCAuthManager {
    let apiRouter = SCAPIRouter()
    
    func startAuthenticateStackExchange(_ completion: ((Result<String, Error>) -> ())?) {
        apiRouter.authenticateStackOverflow { (result, response) in
            switch result {
            case .success(let html):
                if let responseURL = response?.url, responseURL.path == "/oauth/login_success" {
                    setAccessTokenUserDefault(responseURL.extractAccessToken())
                    completion?(.success("/oauth/login_success"))
                } else {
                    completion?(.success(html))
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    func deAuthenticate(_ completion: @escaping (Result<Bool, Error>) -> ()) {
        apiRouter.deautheticate { (result) in
            switch result {
            case .success:
                setAccessTokenUserDefault("")
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    
}
