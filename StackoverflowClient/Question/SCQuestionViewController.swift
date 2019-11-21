//
//  SCQuestionViewController.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit

enum SCQuestonRequestConfig {
    case allPosts(SCQuestionSortType)
    case myPost(SCQuestionSortType)
    case tag(String, SCQuestionSortType)
    case none
}

enum SCQuestionNavigationType: String {
    case allPosts = "All Posts"
    case myPosts = "My Posts"
    case none
}

class SCQuestionViewController: UIViewController {

    private enum Constants {
        static let questionCellReuseID = "QuestionCell"
        static let questionVCID = "QuestionVC"
        static let mainStoryboard = "Main"
        static let settingsSegue = "SettingsSegue"
    }
    
    var config: SCQuestonRequestConfig = .allPosts(.activity) {
        didSet {
            
            if !questionViewModel.isPaginationRequestEnable {
                questionViewModel.currentPage = 1
            } else {
                questionViewModel.currentPage += 1
            }
            
            switch config {
                case .myPost:
                    if questionViewModel.isAuthenticated {
                        fallthrough
                    }
                default:
                    if activityIndicator != nil {
                        activityIndicator.startAnimating()
                    }
            }
            
            questionViewModel.getQuestion(config) { [weak self] (result) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.activityIndicator.stopAnimating()
                strongSelf.refershControl?.endRefreshing()
                switch result {
                    case .success:
                        strongSelf.updateUI()
                    case .failure(let error):
                        strongSelf.presentAlert(error.localizedDescription) {
                            strongSelf.updateUI()
                        }
                }
            }
        }
    }
    
    private var questionViewModel = SCQuestionViewModel()
    
    @IBOutlet weak var noQuestionView: UIView!
    @IBOutlet weak var questionTableView: UITableView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var refershControl: UIRefreshControl? = nil
    
    var questionNavigationType: SCQuestionNavigationType = .allPosts
    
    // MARK: View Controller - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTableViewSetup()
        initialConfigSetup()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func questionTableViewSetup() {
        questionTableView.estimatedRowHeight = CGFloat(44.0)
        questionTableView.rowHeight = UITableView.automaticDimension
        questionTableView.dataSource = self
        questionTableView.delegate = self
        questionTableView.prefetchDataSource = self
        configPullToRefresh()
    }
    
    private func configPullToRefresh() {
        let pullToRefreshController = UIRefreshControl()
        pullToRefreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullToRefreshController.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        questionTableView.addSubview(pullToRefreshController)
        refershControl = pullToRefreshController
    }
    
    private func initialConfigSetup() {
        switch questionNavigationType {
            case .allPosts:
                config = .allPosts(.activity)
            case .myPosts:
                config = .myPost(.activity)
            case .none:
                break
        }
    }
    
    func updateUI() {
        if questionViewModel.requestInprogress {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        loginButton.isHidden = questionViewModel.isNeedToHideLoginButton
        noQuestionView.isHidden = questionViewModel.isNeedToHideNoQuestionView
        questionTableView.isHidden = questionViewModel.isNeedToHideQuestionTableView
        
        if questionViewModel.isNeedToReloadTableView {
            questionTableView.reloadData()
        }
        
        if questionViewModel.isNeedToIncludeSettingsBarButtonItem {
            let settingsBarButtonItem = UIBarButtonItem(image: UIImage(named: "Settings"), style: .plain, target: self, action: #selector(SCQuestionViewController.settingsButtonPressed(_:)))
            self.navigationItem.setLeftBarButton(settingsBarButtonItem, animated: true)
        } else {
            self.navigationItem.setLeftBarButton(nil, animated: true)
        }
        
        if questionViewModel.isNeedToShowFilter {
            let filterBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "SortIcon"), style: .plain, target: self, action: #selector(SCQuestionViewController.sortButtonPressed(_:)))
            self.navigationItem.setRightBarButton(filterBarButtonItem, animated: true)
        } else {
            self.navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loginVC = segue.destination as? SCLoginViewController {
            loginVC.successLoginCompletion = { [weak self] () -> () in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.updateConfig()
            }
        } else if let settingsVC = segue.destination as? SCSettingsViewController {
            settingsVC.logOutSuccessCompletion = { [weak self] () -> () in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.updateUI()
            }
        }
    }
    
}

// MARK: Event Handlers

extension SCQuestionViewController {
    
    @objc func sortButtonPressed(_ sender: Any?) {
        let bottomSortActionSheet = UIAlertController.init(title: "Sort By", message: "Select questions sort type.", preferredStyle: .actionSheet)
        
        let actionHandler: ((UIAlertAction) -> Void)? = { [weak self] (action) in
            guard let strongSelf = self else {
                return
            }
            
            guard let actionTitle = action.title, let sortType = SCQuestionSortType(rawValue: actionTitle) else {
                return
            }
            
            switch strongSelf.config {
                case .allPosts:
                    strongSelf.config = .allPosts(sortType)
                case .myPost:
                    strongSelf.config = .myPost(sortType)
                case .tag(let tag, _):
                    strongSelf.config = .tag(tag, sortType)
                case .none:
                    break
            }
        
        }
        
        let activity = UIAlertAction.init(title: SCQuestionSortType.activity.rawValue, style: .default, handler: actionHandler)
        let hot = UIAlertAction.init(title: SCQuestionSortType.hot.rawValue, style: .default, handler: actionHandler)
        let votes = UIAlertAction.init(title: SCQuestionSortType.votes.rawValue, style: .default, handler: actionHandler)
        let creation = UIAlertAction.init(title: SCQuestionSortType.creation.rawValue, style: .default, handler: actionHandler)
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        switch questionViewModel.currentSortType {
            case .activity:
                activity.setValue(true, forKey: "checked")
            case .hot:
                hot.setValue(true, forKey: "checked")
            case .votes:
                votes.setValue(true, forKey: "checked")
            case .creation:
                creation.setValue(true, forKey: "checked")
        }
        
        bottomSortActionSheet.addAction(activity)
        bottomSortActionSheet.addAction(hot)
        bottomSortActionSheet.addAction(votes)
        bottomSortActionSheet.addAction(creation)
        bottomSortActionSheet.addAction(cancel)
        
        self.present(bottomSortActionSheet, animated: true, completion: nil)
    }
    
    @objc func pullToRefresh() {
        refershControl?.beginRefreshing()
        questionViewModel.isPaginationRequestEnable = false
        updateConfig()
    }
    
    @objc func settingsButtonPressed(_ sender: Any?) {
        self.performSegue(withIdentifier: Constants.settingsSegue, sender: nil)
    }
    
    @IBAction func reloadButtonPressed(_ sender: Any?) {
        updateConfig()
    }
    
    /*
     * Update Config from Pull to refresh, Success login completion, Reload Button
     */
    
    func updateConfig() {
        switch config {
            case .allPosts(let sort):
                config = .allPosts(sort)
            case .myPost(let sort):
                config = .myPost(sort)
            case .tag(let tag, let sort):
                config = .tag(tag, sort)
            case .none:
                break
        }
    }
}

// MARK: Table View DataSource & Delegate

extension SCQuestionViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        questionViewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch questionViewModel.getCellType(indexPath) {
            case .question:
                let questionCell = questionViewModel.getTableViewCell(tableView, indexPath, SCQuestionTableViewCell.self)
                let question = questionViewModel.questions[indexPath.row]
                questionCell.delegate = self
                let cellViewModel = SCQuestionCellViewModel(question)
                questionCell.configureQuestionCell(cellViewModel)
                return questionCell
            case .loader:
                return questionViewModel.getTableViewCell(tableView, indexPath, SCQuestionTableViewCell.self)
        }
    }
    
    // Table View Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    // Table View Data Source Prefetch
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        guard questionViewModel.isNeedToIncludePaginationLoaderCell && !questionViewModel.isPaginationRequestEnable else {
            return
        }
        
        if indexPaths.contains(questionViewModel.paginationIndexPath()) {
            questionViewModel.isPaginationRequestEnable = true
            updateConfig()
        }
        
    }
    
}

// MARK: SCQuestionTableViewCellDelegate Implemenation

extension SCQuestionViewController: SCQuestionTableViewCellDelegate {
    
    func pushToQuestionVCOnTagPress(_ tag: String) {
        let mainStoryboard = UIStoryboard(name: Constants.mainStoryboard, bundle: nil)
        guard let questionVC = mainStoryboard.instantiateViewController(withIdentifier: Constants.questionVCID) as? SCQuestionViewController else {
            return
        }
        questionVC.questionNavigationType = .none
        questionVC.config = .tag(tag, .activity)
        
        self.navigationController?.pushViewController(questionVC, animated: true)
    }
    
}
