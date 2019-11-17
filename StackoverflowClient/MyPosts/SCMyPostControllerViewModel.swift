//
//  SCMyPostControllerViewModel.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit

class SCMyPostControllerViewModel: NSObject {

    var isNeedToHideLoginButton: Bool {
        !access_token.isEmpty
    }
    
    var isNeedToConfigQuestionVC: Bool {
        !access_token.isEmpty
    }
    
    var isNeedToHideQuestionContainerView: Bool {
        access_token.isEmpty
    }
    
}
