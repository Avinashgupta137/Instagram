//
//  ProfilePresentedView.swift
//  InstaUiKit
//
//  Created by IPS-161 on 13/12/23.
//

import UIKit

class ProfilePresentedView: UIViewController {
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    var user : UserModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        setBlurView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(disMiss))
        mainView.isUserInteractionEnabled = true
        mainView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }
    
    @objc func disMiss(){
        dismiss(animated: true)
    }
    
    func setBlurView() {
        let blurView = UIVisualEffectView()
        blurView.frame = view.frame
        blurView.effect = UIBlurEffect(style: .regular)
        mainView.addSubview(blurView)
        mainView.addSubview(mainStackView)
    }
    
    func updateView() {
        if let user = user, let imgUrl = user.imageUrl, let name = user.name, let userName = user.username, let bio = user.bio {
            DispatchQueue.main.async { [weak self] in
                ImageLoader.loadImage(for: URL(string: imgUrl), into: (self?.userImg)!, withPlaceholder: UIImage(systemName: "person.fill"))
                self?.nameLbl.text = name
                self?.userNameLbl.text = userName
                self?.bioLbl.text = bio
                
                // Add 360-degree rotating effect to userImg
                let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
                rotationAnimation.toValue = NSNumber(value: Double.pi * 2.0)
                rotationAnimation.duration = 3.0  // Adjust the duration as needed
                rotationAnimation.delegate = self // Set the animation delegate
                self?.userImg.layer.add(rotationAnimation, forKey: "rotationAnimation")
            }
        }
    }
    
}

extension ProfilePresentedView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            userImg.layer.removeAllAnimations()
        }
    }
}
