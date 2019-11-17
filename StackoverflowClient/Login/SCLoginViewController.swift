//
//  SCLoginViewController.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit
import WebKit

class SCLoginViewController: UIViewController {

    @IBOutlet weak var authWebView: WKWebView!
    
    var authManager = SCAuthManager()
    var successLoginCompletion: (() -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authWebView.navigationDelegate = self
        authManager.startAuthenticateStackExchange { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let urlPath) where urlPath == "/oauth/login_success":
                strongSelf.dismiss(animated: true, completion: strongSelf.successLoginCompletion)
            case .success(let html):
                let baseURL = URL(string: "https://stackoverflow.com")
                strongSelf.authWebView.loadHTMLString(html, baseURL: baseURL)
            case .failure(let error):
                strongSelf.presentAlert(error.localizedDescription)
            }
            
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

extension SCLoginViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let responseURL = navigationResponse.response.url else {
            presentAlert("No Response URL.")
            decisionHandler(.cancel)
            return
        }
        
        if responseURL.host == "m.facebook.com" || responseURL.host == "stackoverflow.com" || responseURL.host == "www.google.com" {
            decisionHandler(.allow)
        } else if responseURL.path == "/oauth/login_success" {
            decisionHandler(.allow)
            setAccessTokenUserDefault(responseURL.extractAccessToken())
            presentAlert("Logged in successfully.") { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.dismiss(animated: true, completion: strongSelf.successLoginCompletion)
            }
        } else {
            decisionHandler(.cancel)
            presentAlert("Kindy authenticate using fb. No other login supported.")
        }
        
    }
    
}