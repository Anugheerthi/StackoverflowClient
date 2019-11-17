//
//  SCQuestionCellViewModel.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit

class SCQuestionCellViewModel: NSObject {

    private var questionInfo: SCQuestionInfo!
    
    init(_ questionInfo: SCQuestionInfo) {
        self.questionInfo = questionInfo
    }
    
    var questionTitle: String {
        questionInfo.questionTitle
    }
    
    var upvoteCount: String {
        "\(questionInfo.questionScore)"
    }
    
    var tags: [String] {
        questionInfo.questionTags
    }
    
    var timestampWithPosterName: String {
        guard !questionInfo.questionPosterUserName.isEmpty, !posterTimeStamp.isEmpty else {
            return ""
        }
        
        return "asked \(posterTimeStamp) by \(questionInfo.questionPosterUserName)"
    }
    
    private var posterTimeStamp: String {
        let timeMilliseconds = TimeInterval(questionInfo.questionLastEditDate != 0 ? questionInfo.questionLastEditDate : questionInfo.questionCreationDate)
        let date = Date(timeIntervalSince1970: timeMilliseconds)
        return Date.getTimeStampText(date)
    }

}