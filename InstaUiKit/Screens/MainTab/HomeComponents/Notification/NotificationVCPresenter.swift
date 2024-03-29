//
//  NotificationVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation

protocol NotificationVCPresenterProtocol {
    func viewDidload()
    func fetchCurrentUser()
    func goToUsersProfileView(user:UserModel , isFollowAndMsgBtnShow : Bool)
    var currentUser : UserModel? { get set }
}

class NotificationVCPresenter {
    weak var view : NotificationVCProtocol?
    var interactor : NotificationVCInteractorProtocol
    var router : NotificationVCRouterProtocol
    var currentUser : UserModel?
    init(view:NotificationVCProtocol,interactor:NotificationVCInteractorProtocol , router :NotificationVCRouterProtocol ){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension NotificationVCPresenter : NotificationVCPresenterProtocol {
    
    func viewDidload(){
        
    }
    
    func fetchCurrentUser() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.interactor.fetchCurrentUser { result in
                switch result {
                case .success(let data):
                    print(data)
                    self.currentUser = data
                    DispatchQueue.main.async {
                        self.view?.configureTableView()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func goToUsersProfileView(user: UserModel, isFollowAndMsgBtnShow: Bool) {
        router.goToUsersProfileView(user: user, isFollowAndMsgBtnShow: isFollowAndMsgBtnShow)
    }
    
}
