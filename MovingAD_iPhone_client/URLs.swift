//
//  URLs.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/20.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import Foundation

class MADURL {
    // Mark urls
    static var ip = "115.28.206.58"
//    static var ip = "q137368440.xicp.net"
    static var port = "5000"
    
    class var baseURL: String {
        get {
            return "http://\(MADURL.ip):\(port)"
        }
    }
    
    class var login: String {
        get {
            return "\(MADURL.baseURL)/app/check_login/"
        }
    }

    class var get_driver_info: String {
        get {
            return "\(MADURL.baseURL)/app/get_driver_info/"
        }
    }

    class func get_advs(meter meter: Int, lng: Double, lat: Double) -> String {
        return "\(MADURL.baseURL)/app/get_advs/\(meter)/\(lng)/\(lat)/"
    }

    class func get_register_code(withPhone phone: String) -> String {
        return "\(MADURL.baseURL)/app/get_register_code/\(phone)/"
    }

    class var check_register_code: String {
        get {
            return "\(MADURL.baseURL)/app/check_register_code/"
        }
    }

    class var check_register: String {
        get {
            return "\(MADURL.baseURL)/app/check_register/"
        }
    }

    //forget
    class func get_login_code(phone: String) -> String {
        return "\(MADURL.baseURL)/app/get_login_code/\(phone)/"
    }

    class var check_login_code: String {
        get {
            return "\(MADURL.baseURL)/app/check_login_code/"
        }
    }

    class func post_adv<T>(adv_ID: T) -> String {
        return "\(MADURL.baseURL)/app/post_adv/\(adv_ID)"
    }

    class var get_records: String {
        get {
            return "\(MADURL.baseURL)/app/get_records/"
        }
    }
    
    
    //parameters
    class param {
        static let phone = "phone"
        static let password = "password"
        static let verifyCode = "register_code"
        static let name = "name"
        static let gender = "gender"
    }
    
    
    //e.g. statusCodeDictionary[status][0]   statusCodeDictionary[status][1]
    static let statusCodeDictionary = [
        "000": ["无法连接服务器", false],
        "200": ["登陆成功", true],
        "210": ["账号不存在或密码不正确", false],
        "300": ["验证码已发送", true],
        "310": ["手机号已被注册", false],
        "320": ["验证码正确", true],
        "330": ["验证码不正确", false],
        "340": ["注册成功", true],
        "350": ["注册失败", false],
        "403": ["用户被封禁", false],
        "400": ["广告可发送", true],
        "410": ["广告不可发送", false]
    ]
}

/*
 
 登陆接口
 baseURL/login POST
 参数
 "account": string not null
 "password": string not null
 
 返回json串
 说明: error 和 userinfo 至少一个不为 null, error 的数字代表出错信息代码。
 {
    "error": int can null,
    "userinfo": {"name": string can null} can null
 }
 
 
 注册接口
 baseURL/register POST
 参数
 "account": string not null
 "password": string not null
 "name": string can null
 
 返回json串
 说明: 同login返回要求。
 {
    "error": int can null,
    "userinfo": {"name": string can null} can null
 }
 */