//
//  AddChatVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 06/12/23.
//

import UIKit

protocol passChatUserBack {
    func passChatUserBack(user: UserModel?)
}

class AddChatVC: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewOutlet: UITableView!

    var allUniqueUsersArray: [UserModel]?
    var filteredUsers: [UserModel]?
    var delegate: passChatUserBack?
    let dispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchAllUsers()
    }

    private func setupUI() {
        searchBar.delegate = self
        addDoneButtonToSearchBarKeyboard()
    }

    private func setupTableView() {
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
    }

    func fetchAllUsers() {
        if let allUniqueUsersArray = allUniqueUsersArray {
            filteredUsers = allUniqueUsersArray
        }
        tableViewOutlet.reloadData()
    }

    func addDoneButtonToSearchBarKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [flexibleSpace, doneButton]
        searchBar.inputAccessoryView = toolbar
    }

    @objc func doneButtonTapped() {
        searchBar.resignFirstResponder()
    }
}

extension AddChatVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // If the search bar is empty, show all users
            filteredUsers = allUniqueUsersArray
        } else {
            // Filter users based on the search text
            filteredUsers = allUniqueUsersArray?.filter { user in
                return user.name?.lowercased().contains(searchText.lowercased()) == true
            }
        }
        tableViewOutlet.reloadData()
    }
}

extension AddChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddChatVCCell", for: indexPath) as! AddChatVCCell

        if let cellData = filteredUsers?[indexPath.row],
           let imgUrl = cellData.imageUrl,
           let name = cellData.name,
           let userName = cellData.username {
            ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            cell.nameLbl.text = name
            cell.userNameLbl.text = userName
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Alert.shared.alertYesNo(title: "Add Chat User", message: "Do you want to add the user to the chat section?", presentingViewController: self) { _ in
            if let user = self.filteredUsers?[indexPath.row] {
                self.delegate?.passChatUserBack(user: user)
            }
            self.dismiss(animated: true)
        } noHandler: { _ in
            print("No")
        }
    }
}
