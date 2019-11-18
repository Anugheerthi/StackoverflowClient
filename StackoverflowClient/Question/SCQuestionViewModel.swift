//
//  SCQuestionViewModel.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit

class SCQuestionViewModel: NSObject {

    private let getQuestRouter = SCAPIRouter()
    
    private var getQuestionRequestCompletion: SCQuestionResponseBlock = nil
    
    private var questionsModel: SCQuestions? = nil {
        didSet {
            guard let newQuestions = questionsModel?.items else {
                return
            }
            if !isPaginationRequestEnable {
                questions.removeAll()
            }
            questions.append(contentsOf: newQuestions)
        }
    }
    
    var questions = [SCQuestion]()
    
    var currentSortType: SCQuestionSortType = .activity
    
    private var currentConfig: SCQuestonRequestConfig = .none
    
    var isPaginationRequestEnable = false
    
    var requestInprogress = false
    
    typealias SCQuestionResponse = (Result<[SCQuestion], Error>) -> ()
    
    func getQuestion(_ config: SCQuestonRequestConfig, isPagination: Bool = false, completion: @escaping SCQuestionResponse) {
        
        currentConfig = config
        switch config {
            case .myPost:
                if !isAuthenticated {
                    return
                }
            default:
                break
        }
        
        getQuestionRequestCompletion = { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.requestInprogress = false
            switch result {
                case .success(let questions):
                    strongSelf.questionsModel = questions
                    completion(.success(strongSelf.questions))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        requestInprogress = true
        getQuestionsBasedOnConfig(config)
    }
    
    func getQuestionsBasedOnConfig(_ config: SCQuestonRequestConfig) {
        switch config {
            case .allPosts(let sort):
                getAllPosts(sort)
            case .myPost(let sort):
                getMyPosts(sort)
            case .tag(let tag, let sort):
                getPostByTag(tag, sort)
            case .none:
                break
        }
    }
    
    // VM Properties
    
    var isNeedToHideNoQuestionBanner: Bool {
        questions.count != 0
    }
    
    var sortButtonTitle: String {
        currentSortType.rawValue
    }
    
    // Pagination Handler
    
    var currentPage = 1
    
    var isPageEndReaches:  Bool = false {
        didSet {
            
        }
    }
    
    var hasMoreContent: Bool {
        return questionsModel?.hasMore ?? false
    }
    
    // Login Button
    
    var isAuthenticated: Bool {
        return !access_token.isEmpty
    }
    
    var isNeedToHideLoginButton: Bool {
        switch currentConfig {
            case .myPost:
                return isAuthenticated
            default:
                return true
        }
    }
    
    var isNeedToHideNoQuestionView: Bool {
        guard !requestInprogress else {
            return true
        }
        switch currentConfig {
            case .myPost:
                return !isAuthenticated || (isAuthenticated && !questions.isEmpty)
            default:
                return !questions.isEmpty
        }
    }
    
    var isNeedToHideQuestionTableView: Bool {
        switch currentConfig {
            case .myPost:
                return !isAuthenticated || (isAuthenticated && questions.isEmpty)
            default:
                return questions.isEmpty || requestInprogress
        }
    }
    
    var isNeedToReloadTableView: Bool {
        switch currentConfig {
            case .myPost:
                return isAuthenticated && !questions.isEmpty
            default:
                return !questions.isEmpty
        }
    }
    
    var isNeedToIncludeSettingsBarButtonItem: Bool {
        switch currentConfig {
            case .myPost:
                return isAuthenticated
            default:
                return false
        }
    }
    
    var isNeedToShowFilter: Bool {
        !isNeedToHideQuestionTableView
    }
    
    var isNeedToIncludePaginationLoaderCell: Bool {
        return hasMoreContent
    }
    
    var numberOfRows: Int {
        isNeedToIncludePaginationLoaderCell ? questions.count + 1 : questions.count
    }
    
    func paginationIndexPath() -> IndexPath {
        return IndexPath(row: questions.count, section: 0)
    }
    
    func getCellType(_ indexPath: IndexPath) -> SCQuestionTableViewCellType {
        guard isNeedToIncludePaginationLoaderCell else {
            return .question
        }
 
        return indexPath.row == paginationIndexPath().row ? .loader : .question
    }
    
    func getTableViewCell<T: UITableViewCell>(_ tableView: UITableView, _ indexPath: IndexPath, _ customTableCellClass: T.Type) -> T {
        guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: getCellType(indexPath).rawValue, for: indexPath) as? T else {
            return T()
        }
        
        return tableViewCell
    }
    
}

enum SCQuestionTableViewCellType: String {
    case question = "QuestionCell"
    case loader = "LoaderCell"
}


extension SCQuestionViewModel {
    
    func getAllPosts(_ sort: SCQuestionSortType) {
        currentSortType = sort
        getQuestRouter.getQuestions(currentPage, sort, completion: getQuestionRequestCompletion)
    }
    
    func getMyPosts(_ sort: SCQuestionSortType) {
        currentSortType = sort
        getQuestRouter.getMyQuestions(currentPage, sort, completion: getQuestionRequestCompletion)
    }
    
    func getPostByTag(_ tag: String, _ sort: SCQuestionSortType) {
        currentSortType = sort
        getQuestRouter.getQuestionByTag(tag, currentPage, sort, completion: getQuestionRequestCompletion)
    }
    
}
