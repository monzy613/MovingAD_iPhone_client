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
    var account_money: Float = 0.0
    var id: String?
    var account_ID: String?
    var checkState: String

    static var currentUserInfo: MADUserInfo?

    init(json: JSON) {
        name = json["user_name"].string
        phone = json["phone"].string
        id = json["user_ID"].string
        account_money = json["account_money"].float ?? 0.0
        account_ID = json["account_ID"].string
        checkState = json["check_flag"].string ?? "未审核"
    }
}