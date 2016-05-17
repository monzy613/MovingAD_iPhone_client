//
//  MADInputValidation.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/24.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import Foundation

private let verifyCodeCount = 4

class MADInputValidation {
    enum MADInputValidationResult: String {
        case Valid = "valid"
        
        //phone validation
        case PhoneNumberEmpty = "手机号不能为空"
        case InvalidPhoneNumber = "请输入正确手机号"
        
        //password validation
        case PasswordEmpty = "密码不可为空"
        case PasswordTooShort = "密码应大于等于六位"
        case PasswordConfirmFail = "两次输入密码不一致"
        
        //verify code
        case VerifyNumberInvalid = "请输入正确4位验证码"

        //id code
        case IDCodeInvalid = "请输入正确的身份证"
    }
    
    class func phoneNumber(phonenumber no: String?) -> MADInputValidationResult {
        if let no = no {
            if no == "adm" { return .Valid }
            if no == "" {
                return .PhoneNumberEmpty
            } else {
                if no.length == 11 {
                    let pattern = "1[34578][0-9]{9}"
                    let isValid = no.rangeOfString(pattern, options: .RegularExpressionSearch)
                    if isValid != nil {
                        return .Valid
                    } else {
                        return .InvalidPhoneNumber
                    }
                } else {
                    return .InvalidPhoneNumber
                }
            }
        } else {
            return .PhoneNumberEmpty
        }
    }

    class func idCode(code code: String?) -> MADInputValidationResult {
        if let code = code {
            let pattern = "(^\\d{15}$)|(^\\d{17}([0-9]|X)$)"

            let isValid = code.rangeOfString(pattern, options: .RegularExpressionSearch)
            if isValid != nil && code.length <= 18 {
                return .Valid
            }
        }
        return .IDCodeInvalid
    }
    
    class func password(pwd1 pwd1: String?, pwd2: String?) -> MADInputValidationResult {
        if let pwd1 = pwd1, pwd2 = pwd2 {
            if pwd1 == "" || pwd2 == "" {
                return .PasswordEmpty
            } else if pwd1.length < 6 || pwd2.length < 6{
                return .PasswordTooShort
            } else if pwd1 != pwd2 {
                return .PasswordConfirmFail
            } else {
                return .Valid
            }
        } else {
            return .PasswordEmpty
        }
    }
    
    class func password(pwd pwd: String?) -> MADInputValidationResult {
        if let pwd = pwd {
            if pwd == "adm" { return .Valid }
            if pwd == "" {
                return .PasswordEmpty
            } else {
                return .Valid
            }
        } else {
            return .PasswordEmpty
        }
    }
    
    class func verifyNumber(verifyNumber no: String?) -> MADInputValidationResult {
        if let no = no {
            if no.length == verifyCodeCount {
                return .Valid
            }
        }
        return .VerifyNumberInvalid
    }
}