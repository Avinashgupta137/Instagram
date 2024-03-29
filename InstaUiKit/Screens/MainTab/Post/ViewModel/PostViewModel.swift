//
//  PostViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//

import Foundation
import Photos
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import Firebase

class PostViewModel {
    static let shared = PostViewModel()
    var imagesArray: [UIImage] = []
    let dispatchGroup = DispatchGroup()
    private init(){}
    
    func uploadImagesToFirebaseStorage(images: [UIImage], caption: String, location: String, completionHandler: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var downloadURLs: [String] = []
        
        for (index, image) in images.enumerated() {
            group.enter()
            
            let imageName = "\(Int(Date().timeIntervalSince1970))_\(index).jpg"
            let storageRef = Storage.storage().reference().child("images/\(imageName)")
            
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Error uploading image \(index): \(error.localizedDescription)")
                        group.leave()
                    } else {
                        storageRef.downloadURL { (url, error) in
                            if let downloadURL = url {
                                print("Image \(index) uploaded to: \(downloadURL)")
                                downloadURLs.append(downloadURL.absoluteString)
                                group.leave()
                            } else {
                                print("Error getting image \(index) download URL: \(error?.localizedDescription ?? "")")
                                group.leave()
                            }
                        }
                    }
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // All images have been uploaded
            guard !downloadURLs.isEmpty, let uid = Auth.auth().currentUser?.uid else {
                print("User is not authenticated or no images uploaded.")
                completionHandler(false)
                return
            }
            
            let db = Firestore.firestore()
            var imageDocData: [String: Any] = [
                "postImageURLs": downloadURLs,
                "caption": caption,
                "location": location,
                "uid": uid,
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            db.collection("post").addDocument(data: imageDocData) { (error) in
                if let error = error {
                    print("Error adding document: \(error)")
                    completionHandler(false)
                } else {
                    print("Document added successfully")
                    completionHandler(true)
                }
            }
        }
    }
    
    
    
    func fetchPostDataOfPerticularUser(forUID uid: String, completion: @escaping (Result<[PostAllDataModel], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("post")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    var posts: [PostAllDataModel] = []
                    for document in querySnapshot!.documents {
                        self.dispatchGroup.enter()
                        let data = document.data()
                        let postImageURLs = data["postImageURLs"] as? [String] ?? []
                        let caption = data["caption"] as? String ?? ""
                        let location = data["location"] as? String ?? ""
                        let uid = data["uid"] as? String ?? ""
                        let postDocumentID = document.documentID // Get document ID
                        let likedBy = data["likedBy"] as? [String] ?? []
                        let likesCount = data["likesCount"] as? Int ?? 0
                        let comments = data["comments"] as? [[String: Any]] ?? []
                        if let timestamp = data["timestamp"] as? Timestamp {
                            FetchUserData.shared.fetchUserDataByUid(uid: uid) { result in
                                switch result {
                                case.success(let user):
                                    if let user = user , let name = user.name , let userName = user.username , let profilrImgUrl = user.imageUrl{
                                        posts.append(PostAllDataModel(postImageURLs: postImageURLs, caption: caption, location: location, name: name, uid: uid, profileImageUrl: profilrImgUrl, postDocumentID: postDocumentID, likedBy: likedBy, likesCount: likesCount, comments: comments, username: userName, timestamp: timestamp))
                                    }
                                case.failure(let error):
                                    print(error)
                                }
                                self.dispatchGroup.leave()
                            }
                        }
                    }
                    self.dispatchGroup.notify(queue: .main) {
                        completion(.success(posts))
                    }
                }
            }
    }
    
    
    func fetchAllPosts(completion: @escaping (Result<[PostAllDataModel], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("post")
            .order(by: "timestamp", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    var posts: [PostAllDataModel] = []
                    for document in querySnapshot!.documents {
                        self.dispatchGroup.enter()
                        let data = document.data()
                        let postImageURLs = data["postImageURLs"] as? [String] ?? []
                        let caption = data["caption"] as? String ?? ""
                        let location = data["location"] as? String ?? ""
                        let uid = data["uid"] as? String ?? ""
                        let postDocumentID = document.documentID
                        let likedBy = data["likedBy"] as? [String] ?? []
                        let likesCount = data["likesCount"] as? Int ?? 0
                        let comments = data["comments"] as? [[String: Any]] ?? []
                        if let timestamp = data["timestamp"] as? Timestamp {
                            FetchUserData.shared.fetchUserDataByUid(uid: uid) { result in
                                switch result {
                                case .success(let user):
                                    guard let user = user, let name = user.name, let userName = user.username, let profileImgUrl = user.imageUrl else {
                                        return
                                    }
                                    let post = PostAllDataModel(
                                        postImageURLs: postImageURLs,
                                        caption: caption,
                                        location: location,
                                        name: name,
                                        uid: uid,
                                        profileImageUrl: profileImgUrl,
                                        postDocumentID: postDocumentID,
                                        likedBy: likedBy,
                                        likesCount: likesCount,
                                        comments: comments,
                                        username: userName,
                                        timestamp: timestamp
                                    )
                                    posts.append(post)
                                case .failure(let error):
                                    print(error)
                                }
                                self.dispatchGroup.leave()
                            }
                        }
                    }
                    self.dispatchGroup.notify(queue: .main) {
                        completion(.success(posts))
                    }
                }
            }
    }
    
    
    
    func fetchPostbyPostDocumentID(byPostDocumentID postDocumentID: String, completion: @escaping (Result<PostAllDataModel?, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("post").document(postDocumentID)
            .getDocument { (documentSnapshot, error) in
                if let error = error {
                    print("Error fetching post data: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    let data = documentSnapshot?.data() ?? [:]
                    let postImageURLs = data["postImageURLs"] as? [String] ?? []
                    let caption = data["caption"] as? String ?? ""
                    let location = data["location"] as? String ?? ""
                    let uid = data["uid"] as? String ?? ""
                    let likedBy = data["likedBy"] as? [String] ?? []
                    let likesCount = data["likesCount"] as? Int ?? 0
                    let comments = data["comments"] as? [[String: Any]] ?? []
                    if let timestamp = data["timestamp"] as? Timestamp {
                        FetchUserData.shared.fetchUserDataByUid(uid: uid) { result in
                            switch result {
                            case.success(let user):
                                if let user = user , let name = user.name , let userName = user.username , let profilrImgUrl = user.imageUrl{
                                    let posts = (PostAllDataModel(postImageURLs: postImageURLs, caption: caption, location: location, name: name, uid: uid, profileImageUrl: profilrImgUrl, postDocumentID: postDocumentID, likedBy: likedBy, likesCount: likesCount, comments: comments, username: userName, timestamp: timestamp))
                                    completion(.success(posts))
                                }
                            case.failure(let error):
                                print(error)
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
    }
    
    
    // Remove trailing closure from likePost and unlikePost methods
    func likePost(postDocumentID: String, userUID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let postDocumentRef = db.collection("post").document(postDocumentID)
        
        // Update the 'likedBy' array to add the user's UID and increment the 'likesCount'
        let batch = db.batch()
        batch.updateData(["likedBy": FieldValue.arrayUnion([userUID])], forDocument: postDocumentRef)
        batch.updateData(["likesCount": FieldValue.increment(Int64(1))], forDocument: postDocumentRef)
        
        batch.commit { error in
            if let error = error {
                print("Error liking post: \(error.localizedDescription)")
                completion(false) // Notify that the operation failed
            } else {
                print("Post liked by user with UID: \(userUID)")
                completion(true) // Notify that the operation succeeded
            }
        }
    }
    
    
    func unlikePost(postDocumentID: String, userUID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let postDocumentRef = db.collection("post").document(postDocumentID)
        
        // Update the 'likedBy' array to remove the user's UID and decrement the 'likesCount'
        let batch = db.batch()
        batch.updateData(["likedBy": FieldValue.arrayRemove([userUID])], forDocument: postDocumentRef)
        batch.updateData(["likesCount": FieldValue.increment(Int64(-1))], forDocument: postDocumentRef)
        
        batch.commit { error in
            if let error = error {
                print("Error unliking post: \(error.localizedDescription)")
                completion(false) // Notify that the operation failed
            } else {
                print("Post unliked by user with UID: \(userUID)")
                completion(true) // Notify that the operation succeeded
            }
        }
    }
    
    
    // Function to increment the likes count for a post
    func incrementLikesCountForPost(postDocumentRef: DocumentReference) {
        postDocumentRef.updateData(["likesCount": FieldValue.increment(Int64(1))]) { error in
            if let error = error {
                print("Error incrementing likes count: \(error.localizedDescription)")
            } else {
                print("Likes count incremented for post")
            }
        }
    }
    
    // Function to decrement the likes count for a post
    func decrementLikesCountForPost(postDocumentRef: DocumentReference) {
        postDocumentRef.updateData(["likesCount": FieldValue.increment(Int64(-1))]) { error in
            if let error = error {
                print("Error decrementing likes count: \(error.localizedDescription)")
            } else {
                print("Likes count decremented for post")
            }
        }
    }
    
    
    func addCommentToPost(postDocumentID: String, commentText: String, completion: @escaping (Bool) -> Void) {
        // Get the current user's UID
        if let userUID = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let postDocumentRef = db.collection("post").document(postDocumentID)
            
            // Create a dictionary to represent the comment
            let commentData: [String: Any] = [
                "uid": userUID,
                "comment": commentText
            ]
            
            // Update the 'comments' array in the post
            let batch = db.batch()
            batch.updateData(["comments": FieldValue.arrayUnion([commentData])], forDocument: postDocumentRef)
            
            batch.commit { error in
                if let error = error {
                    print("Error adding comment to post: \(error.localizedDescription)")
                    completion(false) // Notify that the operation failed
                } else {
                    print("Comment added to post by user with UID: \(userUID)")
                    completion(true) // Notify that the operation succeeded
                }
            }
        } else {
            // Handle the case when the current user is not authenticated
            print("User is not authenticated.")
            completion(false) // Notify that the operation failed
        }
    }
    
}
