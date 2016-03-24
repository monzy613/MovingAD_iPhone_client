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
    static func Post(url url: String, parameters: [String: String]?, onSuccess: Void -> Void, onFailure: Void -> Void) {
        Alamofire.request(.POST, url, parameters: parameters).responseJSON {
            response in
            let json = JSON(response.result.value ?? [])
            if let err = response.result.error {
                print("error: \(err)")
            }
            switch url {
            case MADURL.login:
                if let userinfo = json["userInfo"].dictionaryObject {
                    print(userinfo)
                    onSuccess()
                } else {
                    onFailure()
                    if let error = json["error"].string {
                        print(error)
                    }
                }
                break
            default:
                break
            }
        }
    }
    
}