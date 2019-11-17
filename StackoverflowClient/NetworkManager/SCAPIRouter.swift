//
//  SCAPIRouter.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import Foundation
import Alamofire

enum SCAPI {
    case authenticate
    case question
}

enum ResponseError: String, Error {
    case jsonParser = "Json Parsing error."
    case noData = "No data received."
}

typealias SCQuestionResponseBlock = ((Result<SCQuestions, Error>) -> Void)?

class SCAPIRouter {
    
    private let kHeaderNameAccessToken = "X-API-Access-Token"
    private let kParamNameKey = "key"
    
    private var httpRequestHeader: HTTPHeaders {
        [HTTPHeader(name: kHeaderNameAccessToken, value: access_token)]
    }
    
    private var networkManager = SCNetworkManager()
    
    // MARK: GET QUESTIONS
    
    func getQuestions(_ page: Int, _ sort: SCQuestionSortType, completion: SCQuestionResponseBlock) {
        getQuesions(SCQuestions.allUsersQuestionURLString, parameters: SCQuestions.getQueryParam(page, sort), completion: completion)
    }
    
    func getMyQuestions(_ page: Int, _ sort: SCQuestionSortType, completion: SCQuestionResponseBlock) {
        var queryParam = SCQuestions.getQueryParam(page, sort)
        queryParam[kParamNameKey] = kSE_Key
        getQuesions(SCQuestions.loggedInUserPostedQuestionURLString, parameters: queryParam, headers: httpRequestHeader, completion: completion)
    }
    
    func getQuestionByTag(_ tag: String, _ page: Int, _ sort: SCQuestionSortType, completion: SCQuestionResponseBlock) {
        getQuesions(SCQuestions.faqQuestionByTagURLString(tag), parameters: SCQuestions.getQueryParam(page, sort), completion: completion)
    }
    
    private func getQuesions(_ urlString: String, parameters: Parameters, headers: HTTPHeaders? = nil, completion: SCQuestionResponseBlock) {
        networkManager.cancelRequest()
        networkManager.fetch(urlString, parameters: parameters, headers: headers) { [weak self] (data) in
            guard let strongSelf = self else {
                return
            }
            let result = strongSelf.parse(SCQuestions.self, data)
            completion?(result)
        }
        
    }
    
    
    
    // MARK: AUTHENTICATE
    
    func authenticateStackOverflow(_ completion: @escaping (Result<String, Error>, HTTPURLResponse?) -> ()) {
        networkManager.fetch(SCAuthentication.authURLString, parameters: SCAuthentication.authQueryParam, method: .get) { (data) in
            switch data.result {
            case .success(let value):
                if let value = value {
                    let str = String(decoding: value, as: UTF8.self)
                    completion(.success(str), data.response)
                }
                
            case .failure(let error):
                completion(.failure(error), data.response)
            }
        }
    }
    
    // MARK: DEAUTHENTICATE
    
    func deautheticate(_ completion: @escaping (Result<Bool, Error>) -> ()) {
        let queryParam = [kParamNameKey : kSE_Key]
        networkManager.fetch(SCAuthentication.deAuthenticateURLString, parameters: queryParam, method: .get) { (data) in
            switch data.result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func cancelRequest() {
        networkManager.cancelRequest()
    }
    
}

extension SCAPIRouter {
    
    func parse<T: Decodable>(_ decode: T.Type?, _ data: AFDataResponse<Data?>) -> (Result<T, Error>) {
        switch data.result {
            case .success(let data):
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let parsedData = try jsonDecoder.decode(T.self, from: data)
                        return .success(parsedData)
                    } catch let error {
                        debugPrint("\(error)")
                        return .failure(ResponseError.jsonParser)
                    }
                } else {
                    return .failure(ResponseError.noData)
                }
            case .failure(let error):
                return .failure(error)
        }
    }
    
}
