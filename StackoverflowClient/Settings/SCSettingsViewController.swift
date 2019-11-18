//
//  SCSettingsViewController.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 18/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit

class SCSettingsViewController: UIViewController {
    
    var authManager = SCAuthManager()
    var logOutSuccessCompletion: (() -> ())? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        authManager.deAuthenticate { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success:
                strongSelf.removeCookies()
                strongSelf.presentAlert("Logged Out Successfully.") {
                    strongSelf.dismiss(animated: true, completion: strongSelf.logOutSuccessCompletion)
                }
            case .failure(let error):
                strongSelf.presentAlert(error.localizedDescription)
            }
        }
    }
    
    func removeCookies() {
        let cookieJar = HTTPCookieStorage.shared

        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
