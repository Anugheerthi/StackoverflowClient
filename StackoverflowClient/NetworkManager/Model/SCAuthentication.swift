//
//  SCAuthentication.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 16/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import Foundation
import Alamofire

struct SCAuthentication {
    
    private enum QueryParam: String {
        case clientID = "client_id"
        case scope = "scope"
        case redirect_uri = "redirect_uri"
    }
    
    private enum Scope: String {
        //access a user's global inbox
        case readInbox = "read_inbox"
        //access_token's with this scope do not expire
        case noExpiry = "no_expiry"
        //perform write operations as a user
        case writeAccess = "write_access"
        //access full history of a user's private actions on the site
        case privateInfo = "private_info"
        
        static func getScopeParamValue(_ scopes: [Scope]) -> String {
            scopes.map { $0.rawValue }.joined(separator: ",")
        }
    }
    
    private static var scopeParamValue: String {
        Scope.getScopeParamValue([.readInbox, .noExpiry, .privateInfo])
    }
    
    private static var redirect_uri: String {
        "https://stackexchange.com/oauth/login_success&state"
    }
    
    static var authQueryParam: Parameters {
        [QueryParam.clientID.rawValue : kSE_ClientID,
         QueryParam.scope.rawValue : scopeParamValue,
         QueryParam.redirect_uri.rawValue : redirect_uri]
    }
    
    static var authURLString: String  {
        "https://stackoverflow.com/oauth/dialog?client_id=\(kSE_ClientID)&scope=\(scopeParamValue)&redirect_uri=\(redirect_uri)"
    }
    
    static var deAuthenticateURLString: String {
        return "\(kAPI_BaseURL)/2.2/apps/\(access_token)/de-authenticate"
    }
    
    static let httpMethod: HTTPMethod = .get
    //?client_id=\(kSE_ClientID)&scope=\(scopeParamValue)&redirect_uri=\(redirect_uri)
}
