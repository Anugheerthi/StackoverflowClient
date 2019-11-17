//
//  SCNavigationController.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit

class SCQuestionNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let questionVC = self.topViewController as? SCQuestionViewController else {
            return
        }
        
        if let tabTitle = self.tabBarItem.title, let questionNavigationType = SCQuestionNavigationType.init(rawValue: tabTitle) {
            questionVC.questionNavigationType = questionNavigationType
        }

    }
    

}
