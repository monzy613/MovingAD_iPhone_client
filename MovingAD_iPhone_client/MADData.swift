//
//  MADData.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/24.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import CoreData

enum MADDataKey: String {
    case Account = "MAD.Account"
    case Password = "MAD.Password"
}

class MADData {
    class func save(value value: String?, withKey key: MADDataKey) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key.rawValue)
    }

    class func getValue(withKey key: MADDataKey) -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(key.rawValue)
    }

    class func sweepAllData() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(MADDataKey.Account.rawValue)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(MADDataKey.Password.rawValue)
    }
}