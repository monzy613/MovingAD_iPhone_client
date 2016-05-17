//
//  MADUserInfo.swift
//  MovingAD_iPhone_client
//
//  Created by Monzy Zhang on 5/17/16.
//  Copyright © 2016 MonzyZhang. All rights reserved.
//

import Foundation


class MADUserInfo {
    var name: String?
    var phone: String?
    var account_money: Float?
    var account_ID: String?

    static var currentUserInfo: MADUserInfo?

    init(json: JSON) {
        name = json["user_name"].string
        phone = json["phone"].string
        account_money = json["account_money"].float
        account_ID = json["account_ID"].string
    }
}