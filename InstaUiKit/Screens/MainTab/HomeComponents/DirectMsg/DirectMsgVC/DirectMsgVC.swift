//
//  DirectMsgVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol DirectMsgVCProtocol :class {
    func addDoneButtonToSearchBarKeyboard()
    func configureTableView(chatUsers:[UserModel] , currentUser : UserModel )
}


class DirectMsgVC: UIViewController {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var presenter : DirectMsgVCPresenterProtocol?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
    }
    
    func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    func addChatBtnPressed() {
        presenter?.goToAddChatVC()
    }
    
    @objc func doneButtonTapped() {
        searchBar.resignFirstResponder()
    }
    
}

extension DirectMsgVC : DirectMsgVCProtocol {
    func addDoneButtonToSearchBarKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [flexibleSpace, doneButton]
        searchBar.inputAccessoryView = toolbar
    }
    
    func configureTableView(chatUsers:[UserModel] , currentUser : UserModel ) {
        tableViewOutlet.dataSource = nil
        tableViewOutlet.delegate = nil
        
        let filteredUsers = BehaviorRelay<[UserModel]>(value: chatUsers)
        filteredUsers
            .bind(to: tableViewOutlet
                    .rx
                    .items(cellIdentifier: "DirectMsgCell", cellType: DirectMsgCell.self)) { [weak self] (row, element, cell) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    cell.configureCell(currentUser: currentUser , element: element)
                }
                
                cell.directMsgButtonTapped = { [weak self] in
                    self?.presenter?.goToChatVC(user: element)
                }
                
            }.disposed(by: disposeBag)
        
        tableViewOutlet.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.presenter?.removeItem(at: indexPath.row, viewController: self!)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                let filteredData = chatUsers.filter { user in
                    return query.isEmpty || (user.name?.lowercased().contains(query.lowercased()) == true)
                }
                filteredUsers.accept(filteredData ?? [])
            })
            .disposed(by: disposeBag)
    }
    
}



