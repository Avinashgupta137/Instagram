//
//  DirectMsgVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

protocol DirectMsgVCPresenterProtocol {
    func viewDidload()
    func fetchAllChatUsersAndCurrentUser()
    func fetchAllUniqueUsers()
    func goToAddChatVC()
    func goToChatVC(user: UserModel)
    func removeItem(at index: Int , viewController : UIViewController )
}

class DirectMsgVCPresenter {
    weak var view : DirectMsgVCProtocol?
    var interactor : DirectMsgVCInteractorProtocol
    var router : DirectMsgVCRouterProtocol
    init(view:DirectMsgVCProtocol,interactor:DirectMsgVCInteractorProtocol,router:DirectMsgVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
        NotificationCenterInternal.shared.addObserver(self, selector: #selector(handleNotification), name: .notification)
    }
    
    @objc func handleNotification() {
        DispatchQueue.global(qos: .background).async {
            self.interactor.fetchAllChatUsersAndCurrentUser { chatUsers, currentUser in
                print(chatUsers)
                DispatchQueue.main.async {
                    self.view?.configureTableView(chatUsers: chatUsers , currentUser : currentUser)
                    MessageLoader.shared.hideLoader()
                }
            }
        }
    }
    
}

extension DirectMsgVCPresenter : DirectMsgVCPresenterProtocol {
    
    func goToChatVC(user: UserModel) {
        router.goToChatVC(user: user)
    }
    
    func viewDidload() {
        view?.addDoneButtonToSearchBarKeyboard()
        fetchAllUniqueUsers()
        fetchAllChatUsersAndCurrentUser()
    }
    
    func fetchAllUniqueUsers() {
        interactor.fetchAllUniqueUsers()
    }
    
    func fetchAllChatUsersAndCurrentUser() {
        DispatchQueue.main.async {
            MessageLoader.shared.showLoader(withText: "Fetching Users")
        }
        DispatchQueue.global(qos: .background).async {
            self.interactor.fetchAllChatUsersAndCurrentUser { chatUsers, currentUser in
                print(chatUsers)
                DispatchQueue.main.async {
                    self.view?.configureTableView(chatUsers: chatUsers , currentUser : currentUser)
                    MessageLoader.shared.hideLoader()
                }
            }
        }
    }
    
    func goToAddChatVC(){
        let filteredUsers = interactor.allUniqueUsersArray.filter { newUser in
            return !(interactor.chatUsers?.contains { existingUser in
                return existingUser.uid == newUser.uid
            })!
        }
        router.goToAddChatVC(allUniqueUsersArray: filteredUsers)
    }
    
    func removeItem(at index: Int , viewController : UIViewController ) {
        let alertController = UIAlertController(
            title: "Delete User",
            message: "Are you sure you want to delete this user?",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteUser(at: index)
        })
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func deleteUser(at index: Int ) {
        guard index < interactor.chatUsers?.count ?? 0 else {
            return
        }
        
        let userToDelete =  interactor.chatUsers?[index].uid
        MessageLoader.shared.showLoader(withText: "Removing User")
        
        interactor.removeUserFromChatlistOfSender(receiverId: userToDelete) { [weak self] _ in
            self?.interactor.fetchChatUsers { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        self?.interactor.chatUsers = data
                        self?.interactor.fetchAllChatUsersAndCurrentUser { chatUsers, currentUser in
                            print(chatUsers)
                            DispatchQueue.main.async {
                                self?.view?.configureTableView(chatUsers: chatUsers , currentUser : currentUser)
                                MessageLoader.shared.hideLoader()
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                    MessageLoader.shared.hideLoader()
                }
            }
        }
        
        if let currentUser = interactor.currentUser , let  senderId = interactor.currentUser?.uid , let receiverId = userToDelete {
            StoreUserData.shared.removeUsersChatNotifications(senderId: senderId, receiverId: receiverId) { _ in}
        }
        
    }
    
}


