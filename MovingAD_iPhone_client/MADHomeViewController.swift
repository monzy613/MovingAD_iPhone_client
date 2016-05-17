//
//  MADHomeViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/23.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit
import Alamofire

class MADHomeViewController: UIViewController {
    @IBOutlet weak var avatarImageView: DesignableImageView!
    @IBOutlet weak var username: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDriverInfo()
    }

    // MARK: private
    private func setupDriverInfo() {
        username.text = MADUserInfo.currentUserInfo?.name ?? ""
    }
}
