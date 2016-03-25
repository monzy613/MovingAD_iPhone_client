//
//  NetworkUtil.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/20.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import Foundation
import Alamofire



/*

 无法连接服务器 000
 
 登录过程中
 登陆成功 200
 账号不存在或密码不正确 210
 
 
 注册过程中
 手机号可用 300
 手机号已被注册 310
 验证码正确 320
 验证码不正确 330
 注册成功 340
 注册失败 一般就是无法连接服务器 000
 
 
 */

class MADNetwork {
    static func Post(url url: String, parameters: [String: String]?, onSuccess: String -> Void, onFailure: String -> Void) {
        Alamofire.request(.POST, url, parameters: parameters).responseJSON {
            response in
            let json = JSON(response.result.value ?? [])
            if let err = response.result.error {
                print("error: \(err)")
                onFailure("000")
            }
            if let statusCode = json["status"].string {
                if let tuple = MADURL.statusCodeDictionary[statusCode] {
                    if tuple[1] as! Bool {
                        onSuccess(MADURL.statusCodeDictionary[statusCode]![0] as! String)
                    } else {
                        onFailure(MADURL.statusCodeDictionary[statusCode]![0] as! String)
                    }
                } else {
                    onFailure(MADURL.statusCodeDictionary["000"]![0] as! String)
                }
            } else {
                onFailure(MADURL.statusCodeDictionary["000"]![0] as! String)
            }
            
            switch url {
            case MADURL.login:
                if let userInfo = json["userinfo"].array {
                    print(userInfo)
                } else {
                    print("no userinfo")
                }
            default:
                break
            }
        }
    }
    
}