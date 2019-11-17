//
//  SCQuestion.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 16/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import Foundation
import Alamofire

protocol SCQuestionInfo {
    var questionTitle: String { get }
    var questionScore: Int { get }
    var questionTags: [String] { get }
    var questionPosterUserName: String { get }
    var questionLastActivityDate: Int { get }
    var questionCreationDate: Int { get }
    var questionLastEditDate: Int { get }
}

typealias SCQuestionSortType = SCQuestions.QuestionSortType
typealias SCQuestion = SCQuestions.SCQuestion

struct SCQuestions: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case items
        case hasMore = "has_more"
        case quotaMax = "quota_max"
        case quotaRemaining = "quota_remaining"
    }
    
    var items: [SCQuestion]?
    var hasMore: Bool?
    var quotaMax: Int?
    var quotaRemaining: Int?
    
    struct SCQuestion: Codable, Equatable, SCQuestionInfo {
        
        static func == (lhs: SCQuestion, rhs: SCQuestion) -> Bool {
            lhs.questionID == rhs.questionID
        }
        
        private enum CodingKeys: String, CodingKey {
            case tags
            case owner
            case isAnswered = "is_answered"
            case viewCount = "view_count"
            case acceptedAnswerID = "accepted_answer_id"
            case answerCount = "answer_count"
            case score
            case lastActivityDate = "last_activity_date"
            case creationDate = "creation_date"
            case lastEditDate = "last_edit_date"
            case questionID = "question_id"
            case link
            case title
        }
        
        var tags: [String]?
        var owner: SCOwner?
        var isAnswered: Bool = false
        var viewCount: Int?
        var acceptedAnswerID: Int?
        var answerCount: Int?
        var score: Int?
        var lastActivityDate: Int?
        var creationDate: Int?
        var lastEditDate: Int?
        var questionID: Int?
        var link: String?
        var title: String?
        
        // Derived Properties
        
        var questionTitle: String {
            title ?? ""
        }
        
        var questionScore: Int {
            score ?? 1
        }
        
        var questionTags: [String] {
            tags ?? []
        }
        
        var questionPosterUserName: String {
            return owner?.displayName ?? ""
        }
        
        var questionLastActivityDate: Int {
            lastActivityDate ?? 0
        }
        
        var questionCreationDate: Int {
            creationDate ?? 0
        }
        
        var questionLastEditDate: Int {
            lastEditDate ?? 0
        }
        
        struct SCOwner: Codable {
            
            private enum CodingKeys: String, CodingKey {
                case reputation
                case userID = "user_id"
                case userType = "user_type"
                case profileImage = "profile_image"
                case displayName = "display_name"
                case link
            }
            
            var reputation: Int?
            var userID: Int?
            var userType: String?
            var profileImage: String?
            var displayName: String?
            var link: String?
            
        }
        
    }
    
    private enum QueryParam: String {
        case site
        case page
        case sort
    }
    
    enum QuestionSortType: String {
        case activity = "Activity"
        case hot = "Hot"
        case votes = "Votes"
        case creation = "Creation"
    }
    
    static func getQueryParam(_ page: Int, _ sort: QuestionSortType) -> Parameters {
            [QueryParam.site.rawValue : kSiteID,
             QueryParam.page.rawValue : page,
             QueryParam.sort.rawValue : sort.rawValue]
    }
    
    static var allUsersQuestionURLString: String  {
        "\(kAPI_BaseURL)/questions"
    }
    
    static var loggedInUserPostedQuestionURLString: String {
        "\(kAPI_BaseURL)/me/questions"
    }
    
    static func faqQuestionByTagURLString(_ tag: String) -> String {
        "\(kAPI_BaseURL)/2.2/tags/\(tag)/faq"
    }
    
    static let httpMethod: HTTPMethod = .get

}

