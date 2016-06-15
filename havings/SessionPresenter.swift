//
//  UserPresenter.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import UIKit

class SessionPresenter {

    static func attemptToRegist(){
        //return false
    }
    
    /*
    static func isValidToRegist(controller :UIViewController) -> Bool {
        guard let password = controller.password else {
            return false
        }
        switch isValidToName(password.text) {
            
        }
        
        return false
    }
    
    static func isValidName(name :String?) -> Bool {
        return false
    }
    */
}

enum SessionValueCombination: String {
    
    case NameEmpty = "ユーザー名が入力されていません"
    case NameInvalid = "ユーザー名は100文字以下までです"
    case MailEmpty = "メールアドレスが入力されていません"
    case MailInvalid = "メールアドレスの形式が正しくありません"
    case PasswordEmpty = "パスワードが入力されていません"
    case PasswordInvalid = "パスワードは英数字8文字以上にしてください"
    case Invalid = "入力形式が不正です"
    case Valid

    static func isNameValid(name :String?) -> SessionValueCombination {
        guard let n = name else{
            return .NameEmpty
        }
        
        if(n.isEmpty){
            return .NameEmpty
        }else if(n.characters.count > 100){
            return .NameInvalid
        }
        
        return .Valid
    }
    
    static func isMailValid(mail :String?) -> SessionValueCombination {
        guard let m = mail else {
            return .MailEmpty
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        
        if(m.isEmpty){
            return .MailEmpty
        }else if(!NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(m)){
            return .MailInvalid
        }
        
        return .Valid
    }
    
    static func isPasswordValid(password :String?) -> SessionValueCombination {
        guard let p = password else {
            return .PasswordEmpty
        }
        
        let passwordRegex = "[a-zA-Z0-9]+"

        if(p.isEmpty){
            return .NameEmpty
        }else if(p.characters.count < 8 || p.characters.count > 70){
            return .PasswordInvalid
        }else if(!NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluateWithObject(p)){
            return .PasswordInvalid
        }
        
        return .Valid
    }
    
    static func isValid(name: String?, mail: String?, password: String?) -> SessionValueCombination {
        let nameResult = isNameValid(name)
        if nameResult != .Valid {
            return nameResult
        }
        
        let mailResult = isMailValid(mail)
        if mailResult != .Valid {
            return mailResult
        }
        
        let passwordResult = isPasswordValid(password)
        if passwordResult != .Valid {
            return passwordResult
        }
        
        return .Valid
    }
}