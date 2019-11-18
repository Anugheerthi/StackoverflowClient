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

    var authWebView: WKWebView?
    
    var authManager = SCAuthManager()
    var successLoginCompletion: (() -> ())? = nil
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authWebView = WKWebView.init(frame: .zero)
        authWebView?.addAsSubViewWithEqualConstraintTo(self.view, .init(top: navigationBar.frame.size.height, left: 0.0, bottom: 0.0, right: 0.0))
        authWebView?.navigationDelegate = self
        authManager.startAuthenticateStackExchange { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let urlPath) where urlPath == "/oauth/login_success":
                strongSelf.dismiss(animated: true, completion: strongSelf.successLoginCompletion)
            case .success(let html):
                let baseURL = URL(string: "https://stackoverflow.com")
                strongSelf.authWebView?.loadHTMLString(html, baseURL: baseURL)
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
        guard let responseURL = navigationResponse.response.url, let responseURLCompoent = URLComponents(string: responseURL.absoluteString) else {
            presentAlert("No Response URL.")
            decisionHandler(.cancel)
            return
        }
        
        if responseURLCompoent.host == "m.facebook.com" || responseURLCompoent.host == "stackoverflow.com" || responseURLCompoent.host == "www.google.com" {
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
        } else if responseURLCompoent.fragment == "error=access_denied&error_description=user did not authorize application" {
            decisionHandler(.allow)
            presentAlert("You did not authorize this application.") { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.dismiss(animated: true, completion: nil)
            }
        } else {
            decisionHandler(.cancel)
            presentAlert("Kindy authenticate using fb. No other login supported.")
        }
        
    }
    
}
