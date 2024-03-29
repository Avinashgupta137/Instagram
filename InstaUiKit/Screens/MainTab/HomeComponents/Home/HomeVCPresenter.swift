//
//  HomeVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit


protocol HomeVCPresenterProtocol {
    func viewDidload()
    func fetchAllPostsOfFollowings(completion:@escaping()->())
    func fetchFollowingUsers(completion:@escaping()->())
    func configureTableView()
    func goToDirectMsgVC()
    func goToNotificationVC()
    func fetchAllNotifications(view:UIViewController)
    var allPost : [PostAllDataModel] {get set}
    var allUniqueUsersArray : [UserModel] {get set}
}

class HomeVCPresenter {
    weak var view : HomeVCProtocol?
    var interactor : HomeVCInteractorProtocol
    var router : HomeVCRouterProtocol
    var allPost = [PostAllDataModel]()
    var allUniqueUsersArray = [UserModel]()
    let dispatchGroup = DispatchGroup()
    init(view:HomeVCProtocol,interactor:HomeVCInteractorProtocol,router:HomeVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}

extension HomeVCPresenter : HomeVCPresenterProtocol {
    
    func fetchAllNotifications(view: UIViewController) {
        HomeVCBuilder.fetchAllKindNotifications(view: view)
    }
   
    func viewDidload() {
        view?.confugureCell()
        view?.makeSkeletonable()
        view?.setupRefreshControl()
        configureTableView()
    }
    
    func configureTableView() {
        dispatchGroup.enter()
        fetchAllPostsOfFollowings{
            self.dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchFollowingUsers{
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.view?.configureTableView()
            }
        }
        
    }
    
    func fetchAllPostsOfFollowings(completion:@escaping()->()) {
        interactor.fetchAllPostsOfFollowings { result in
            switch result {
            case.success(let data):
                print(data)
                if let data = data {
                    self.allPost = data
                }
                completion()
            case.failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func fetchFollowingUsers(completion:@escaping()->()) {
        interactor.fetchFollowingUsers { result in
            switch result {
            case.success(let data):
                print(data)
                if let data = data {
                    self.allUniqueUsersArray = data
                }
                completion()
            case.failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func goToDirectMsgVC(){
        router.goToDirectMsgVC()
    }
    
    func goToNotificationVC(){
        router.goToNotificationVC()
    }
    
}
