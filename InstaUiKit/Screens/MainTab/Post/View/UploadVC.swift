//
//  UploadVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 30/10/23.
//

import UIKit

class UploadVC: UIViewController {
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var captionTxtFld: UITextField!
    @IBOutlet weak var locationTxtFld: UITextField!
    @IBOutlet weak var multipleSignImg: UIImageView!
    var img : [UIImage]?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let img = img {
            selectedImg.image = img[0]
            multipleSignImg.isHidden = (img.count > 1 ? false : true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.hidesBackButton = true
        navigationItem.title = "Upload"
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        let shareBtn = UIBarButtonItem(title:"Share", style: .plain, target: self, action: #selector(shareBtnPressed))
        shareBtn.tintColor = UIColor(named: "GlobalBlue")
        navigationItem.rightBarButtonItem = shareBtn
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func shareBtnPressed() {
        Alert.shared.alertYesNo(title: "Confirmation", message: "Are you sure you want to Upload Photo?", presentingViewController: self,
                                yesHandler: { _ in
            
            print("User selected Yes")
            
            MessageLoader.shared.showLoader(withText: "Please wait Uploading..")
            
            if let img = self.img, let caption = self.captionTxtFld.text, let location = self.locationTxtFld.text{
                PostViewModel.shared.uploadImagesToFirebaseStorage(images: img, caption: caption, location: location){ value in
                    if value {
                        MessageLoader.shared.hideLoader()
                        Alert.shared.alertOk(title: "Success!", message: "Your Photo uploaded successfully.", presentingViewController: self){ _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else{
                        MessageLoader.shared.hideLoader()
                        Alert.shared.alertOk(title: "Error!", message: "Your Photo not uploaded.", presentingViewController: self){ _ in}
                    }
                }
            }
        },
                                noHandler: { _ in
            
            print("User selected No")
        }
        )
        
    }
    
}


