//
//  SwitchAccountVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import Foundation

protocol SwitchAccountVCPresenterProtocol {
    func viewDidload()
    func fetchCDUsers()
}

class SwitchAccountVCPresenter {
    weak var view : SwitchAccountVCProtocol?
    var interactor : SwitchAccountVCInteractorProtocol
    init(view:SwitchAccountVCProtocol,interactor:SwitchAccountVCInteractorProtocol){
        self.view = view
        self.interactor = interactor
    }
}

extension SwitchAccountVCPresenter : SwitchAccountVCPresenterProtocol {
    
    func viewDidload() {
        view?.makeTableViewSkeletonable()
        fetchCDUsers()
    }
    
    func fetchCDUsers() {
        Task{
            let coreDataUsers = await interactor.fetchCoreDataUsers()
            interactor.getUsers(cdUsers: coreDataUsers) { user in
                self.view?.fetchUsers(cdUser: coreDataUsers, user: user)
            }
        }
    }
    
}
