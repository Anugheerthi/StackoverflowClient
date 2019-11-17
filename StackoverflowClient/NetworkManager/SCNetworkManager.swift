//
//  SCNetworkManager.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 16/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit
import Alamofire

class SCNetworkManager: NSObject {
    
    var request: DataRequest? = nil
    
    func fetch(_ urlString: String,
               parameters: [String : Any]? = nil,
               method: HTTPMethod = .get,
               headers: HTTPHeaders? = nil,
               completion: @escaping (AFDataResponse<Data?>) -> Void) {
        request = AF.request(urlString, method: method, parameters: parameters, headers: headers)
        request?.response { (data) in
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
    
    func cancelRequest() {
        request?.cancel()
    }
    
}
