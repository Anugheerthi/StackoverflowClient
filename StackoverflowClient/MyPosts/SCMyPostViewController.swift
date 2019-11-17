//
//  SCMyPostViewController.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit

class SCMyPostViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var questionContainerView: UIView!
    
    private var questionVC: SCQuestionViewController? = nil
    private let myPostViewModel = SCMyPostControllerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configViewWithAuth()
    }
    
    func configViewWithAuth() {
        loginButton.isHidden = myPostViewModel.isNeedToHideLoginButton
        questionContainerView.isHidden = myPostViewModel.isNeedToHideQuestionContainerView
        if myPostViewModel.isNeedToConfigQuestionVC {
            questionVC?.config = .myPost(.activity)
        }
    }
    
    @IBAction func unwindToMyPost(_ unwindSegue: UIStoryboardSegue) {
        
        // Use data from the view controller which initiated the unwind segue
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let questionVC = segue.destination as? SCQuestionViewController {
            self.questionVC = questionVC
        }
    }
    

}
