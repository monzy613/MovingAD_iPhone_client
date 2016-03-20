//
//  URLs.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/20.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import Foundation

class URL {
    static let baseURL = ""
    static let login = "\(URL.baseURL)/login"
    static let register = "\(URL.baseURL)/register"
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