//
//  SearchVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import RxSwift
import RxCocoa

class SearchVC: UIViewController {
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var collectionView: UIView!
    var allUniqueUsersArray = [UserModel]()
    var allPost = [PostAllDataModel?]()
    let disposeBag = DisposeBag()
    var currentUser : UserModel?
    var tableViewRefreshControl = UIRefreshControl()
    var collectionViewRefreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FollowingCell", bundle: nil)
        tableViewOutlet.register(nib, forCellReuseIdentifier: "FollowingCell")
        addDoneButtonToSearchBarKeyboard()
        collectionViewOutlet.addSubview(collectionViewRefreshControl)
        collectionViewRefreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        fetchData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        setBarItemsForSearchVC()
    }
    
    
    private func setBarItemsForSearchVC() {
       
    }
    
    @objc func refreshCollectionView() {
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
            self.fetchData()
            self.collectionViewRefreshControl.endRefreshing()
        }
    }
    
    func fetchData(){
        SearchVCViewModel.shared.fetchAllPostURL { result in
            switch result {
            case.success(let data):
                print(data)
                self.allPost = data
                self.updateCollectionView()
            case.failure(let error):
                print(error)
            }
        }
        
        
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case .success(let user):
                if let user = user {
                    self.currentUser = user
                }
                FetchUserData.shared.fetchUniqueUsersFromFirebase { result in
                    switch result {
                    case .success(let data):
                        DispatchQueue.main.async {
                            print(data)
                            self.allUniqueUsersArray = data
                            self.updateTableView()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
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
        searchBar.resignFirstResponder() // Dismiss the keyboard
    }
    
    
}


extension SearchVC {
    func updateTableView() {
        tableViewOutlet.dataSource = nil
        tableViewOutlet.delegate = nil
        // Create a BehaviorRelay to hold the filtered user data
        let filteredUsers = BehaviorRelay<[UserModel]>(value: allUniqueUsersArray)
        // Bind the filtered user data to the table view
        filteredUsers
            .bind(to: tableViewOutlet
                    .rx
                    .items(cellIdentifier: "FollowingCell", cellType: FollowingCell.self)) { (row, element, cell) in
                if let name = element.name , let userName = element.username , let imgUrl = element.imageUrl ,let uid = element.uid {
                    DispatchQueue.main.async {
                        ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                        cell.nameLbl.text = name
                        cell.userNameLbl.text = userName
                        
                        if let user = self.currentUser, let followings = user.followings {
                            if followings.contains(uid) {
                                cell.followBtn.setTitle("Following", for: .normal)
                                cell.followBtn.setTitleColor(.black, for: .normal)
                                cell.followBtn.backgroundColor = .white
                            } else {
                                cell.followBtn.setTitle("Follow", for: .normal)
                                cell.followBtn.setTitleColor(.white, for: .normal)
                                cell.followBtn.backgroundColor = UIColor(named:"GlobalBlue")
                            }
                        }
                        
                        cell.followBtnTapped = { [weak self] in
                            let storyboard = UIStoryboard(name: "MainTab", bundle: nil)
                            let destinationVC = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
                            destinationVC.user = element
                            destinationVC.isFollowAndMsgBtnShow = true
                            self?.navigationController?.pushViewController(destinationVC, animated: true)
                        }
                    }
                }
            }
                    .disposed(by: disposeBag)
        
        // Observe changes in the search bar text
        searchBar.rx.text
            .orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                // Filter the user data based on the search query
                let filteredData = self?.allUniqueUsersArray.filter { user in
                    if query.isEmpty {
                        // Show all users if the query is empty
                        self?.tableView.isHidden = true
                        self?.collectionView.isHidden = false
                        return true
                    } else {
                        // Filter users whose name contains the query
                        self?.tableView.isHidden = false
                        self?.collectionView.isHidden = true
                        return (user.name?.lowercased().contains(query.lowercased()) == true)
                    }
                }
                // Update the filteredUsers BehaviorRelay with the filtered data
                filteredUsers.accept(filteredData ?? [])
            })
            .disposed(by: disposeBag)
    }
}



extension SearchVC {
    func updateCollectionView() {
        collectionViewOutlet.dataSource = nil
        collectionViewOutlet.delegate = nil
        SearchVCViewModel.shared.getComposnalLayout { layout in
            self.collectionViewOutlet.collectionViewLayout = layout
        }
        
        Observable.just(allPost)
            .do(onNext: { [weak self] _ in
                self?.collectionViewOutlet.reloadData()
            })
                .bind(to: collectionViewOutlet
                        .rx
                        .items(cellIdentifier: "SearchVCCollectionViewCell", cellType: SearchVCCollectionViewCell.self)) { (row, element, cell) in
                    DispatchQueue.main.async {
                        if let url = element?.postImageURLs?[0] {
                            ImageLoader.loadImage(for: URL(string: url), into: cell.img, withPlaceholder: UIImage(systemName: "person.fill"))
                        }
                        
                        if let postCount = element?.postImageURLs?.count {
                            cell.multiplePostIcon.isHidden = (postCount > 1 ? false : true)
                        }
                        
                    }
                    // Handle tap action
                    cell.tapAction = { [weak self] in
                        if let data = element {
                            var tempData = [PostAllDataModel]()
                            tempData.append(data)
                            self?.handleCellTap(at: row, data: tempData)
                        }
                    }
                }
                        .disposed(by: disposeBag)
    }
    
    func handleCellTap(at index: Int , data : [PostAllDataModel] ) {
        print(data)
        let storyboard = UIStoryboard.Common
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "FeedViewVC") as! FeedViewVC
        destinationVC.allPost = data
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}
