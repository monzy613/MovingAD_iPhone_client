//
//  NetworkUtil.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/20.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import Foundation
import Alamofire

class MADNetwork {
    
    static func Post(url urlString: String, parameters: [String: AnyObject]?, onSuccess: Void -> Void, onFailure: Void -> Void) {
        Alamofire.request(.POST, URL.login, parameters: parameters).responseJSON {
            response in
            
        }
    }
    
}