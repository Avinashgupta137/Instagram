//
//  SaveData.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/10/23.
//

import Foundation

class Data {
    static let shared = Data()
    private init() {
    }
    
    func saveData<T>(_ data: T?, key: String?, completionhandler: @escaping (Bool) -> Void) {
        if let data = data , let key = key {
            UserDefaults.standard.set(data, forKey: key)
            completionhandler(true)
        }else{
            completionhandler(false)
        }
    }
    
    func getData<T>( key: String?,  completionhandler: @escaping (Result<T, Error>) -> Void) {
        if let key = key  {
            if let retrievedData = UserDefaults.standard.value(forKey: key) as? T {
                completionhandler(.success(retrievedData))
            }
        }else {
            let error = NSError(domain: "Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Data retrieval failed"])
            completionhandler(.failure(error))
        }
   }
    
}

