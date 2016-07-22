//
//  File.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import KeychainAccess

// 参考:
// http://blog.asobicocoro.com/entry/2016/04/15/234133
// https://tech.recruit-mp.co.jp/mobile/studying-swift-generitics/
// http://dev.eyewhale.com/archives/1194


class ApiManager {
    
    static func getBaseUrl() -> String {
        return "https://havings.com:9292"
    }
    
    static let sharedInstance: Alamofire.Manager = {
        
        // Create the server trust policies
        // localhostとかIP直打ちだとATSで弾かれるかもしれないので
        // /etc/hostsでhavings.comを適当に指定してる
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "havings.com": .DisableEvaluation
        ]
        
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        
        return Alamofire.Manager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
}

protocol RequestProtocol: URLRequestConvertible {
    associatedtype ResponseType
    
    var baseURL: String { get }
    var method: Alamofire.Method { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var parameters: [String: AnyObject]? { get }
    var encoding: ParameterEncoding { get }
    
    func fromJson(json: AnyObject) -> Result<ResponseType, NSError>
    func fromJsonByArray(json: AnyObject) -> Result<[ResponseType], NSError>

}

extension RequestProtocol {
    
    var baseURL: String {
        return "https://havings.com:9292"
    }
    
    var method: Alamofire.Method {
        return .GET
    }
    
    var headers: [String: String]? {
        let tokenManager = TokenManager.sharedManager
        if let token = tokenManager.getToken(), let uid = tokenManager.getUid() {
            var result : [String:String] = [:]
            result["X_ACCESS_TOKEN"] = token
            result["X_UID"] = uid
            return result
        }else{
            return nil
        }
    }
    
    var parameters: [String: AnyObject]? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        return .URL
    }
    
    var URLRequest: NSMutableURLRequest {
        let url = "\(baseURL)\(path)"
        let encodedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(
            NSCharacterSet.URLQueryAllowedCharacterSet())
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: encodedUrl!)!)
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.allHTTPHeaderFields = headers
        do {
            if let parameters = parameters {
                mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(
                    parameters, options: NSJSONWritingOptions())
                print(parameters)
            }
        } catch {
            // No-op
        }
        
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        print(mutableURLRequest.allHTTPHeaderFields)
        return mutableURLRequest
    }
    
    func fromJson(json: AnyObject) -> Result<ResponseType, NSError> {
        guard let value = json as? ResponseType else {
            let errorInfo = [NSLocalizedDescriptionKey: "Convert object failed" , NSLocalizedRecoverySuggestionErrorKey: "Good luck!"]
            let error = NSError(domain: "works.t_s", code: 0, userInfo: errorInfo)
            return .Failure(error)
        }
        return .Success(value)
    }
    
    func fromJsonByArray(json: AnyObject) -> Result<[ResponseType], NSError> {
        guard let value = json as? [ResponseType] else {
            let errorInfo = [NSLocalizedDescriptionKey: "Convert object failed" , NSLocalizedRecoverySuggestionErrorKey: "Good luck!"]
            let error = NSError(domain: "works.t_s", code: 0, userInfo: errorInfo)
            return .Failure(error)
        }
        return .Success(value)
    }
}

extension RequestProtocol where ResponseType: Mappable {
    
    func fromJson(json: AnyObject) -> Result<ResponseType, NSError> {        
        guard let value = Mapper<ResponseType>().map(json) else {
            let errorInfo = [ NSLocalizedDescriptionKey: "Mapping object failed" , NSLocalizedRecoverySuggestionErrorKey: "Rainy days never stay." ]
            let error = NSError(domain: "com.example.app", code: 0, userInfo: errorInfo)
            return .Failure(error)
        }
        return .Success(value)
    }
    
    func fromJsonByArray(json: AnyObject) -> Result<[ResponseType], NSError> {
        guard let value = Mapper<ResponseType>().mapArray(json) else {
            let errorInfo = [ NSLocalizedDescriptionKey: "Mapping object failed" , NSLocalizedRecoverySuggestionErrorKey: "Rainy days never stay." ]
            let error = NSError(domain: "com.example.app", code: 0, userInfo: errorInfo)
            return .Failure(error)
        }
        return .Success(value)
    }
    
}

class TokenManager {
    
    static let sharedManager = TokenManager()
    
    private var token : String? = nil
    private var uid : String? = nil
    private var userId: Int? = nil
    
    private init(){
        isTokenAndUidSaved()
    }
    
    private static let keyToToken : String = "accesstoken"
    private static let keyToUid : String = "uid"
    private static let keyToUserId: String = "userid"
    private static let service : String = "work.t_s.havings"
    
    private func setTokenAndUid(token t :String, uid u :String, userId ui: Int){
        token = t
        uid = u
        userId = ui
    }
    
    func getToken() -> String? {
        return token
    }
    
    func getUid() -> String? {
        return uid
    }
    
    func getUserId() -> Int? {
        return userId
    }
    
    func saveTokenAndUid(token t :String, uid u :String, userId ui :Int){
        let keychain = Keychain(service: TokenManager.service)
        keychain[TokenManager.keyToToken] = t
        keychain[TokenManager.keyToUid] = u
        keychain[TokenManager.keyToUserId] = String(ui)
        setTokenAndUid(token: t, uid: u, userId: ui)
    }
    
    func resetTokenAndUid(){
        let keychain = Keychain(service: TokenManager.service)
        keychain[TokenManager.keyToToken] = nil
        keychain[TokenManager.keyToUid] = nil
        token = nil
        uid = nil
    }
    
    func isTokenAndUidSaved() -> Bool {
        let keychain = Keychain(service: TokenManager.service)
        do {
            let t : String? = try keychain.getString(TokenManager.keyToToken)
            let u : String? = try keychain.getString(TokenManager.keyToUid)
            let ui: String? = try keychain.getString(TokenManager.keyToUserId)
            
            if let rawToken = t , let rawUid = u, let rawUserId = ui {
                setTokenAndUid(token: rawToken, uid: rawUid, userId: Int(rawUserId)!)
                return true
            }
            return false
        }catch{
            print("something occured access to keychain")
            return false
        }
    }
}

class API {
    
    class func call<T: RequestProtocol, V where T.ResponseType == V>(request: T, completion: (Result<V, NSError>) -> Void) {
        ApiManager.sharedInstance.request(request)
            .validate(statusCode: 200..<500)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print("response ##########################")
                print(response.result.value)
                print("response end ######################")
                switch response.result {
                case .Success(let json):
                    completion(request.fromJson(json))
                case .Failure(let error):
                    if let statusCode = response.response?.statusCode where 400..<500 ~= statusCode {
                        print("error!!!!")
                        print(error)
                        //completion(.Failure(response.result.value))
                    }
                    completion(.Failure(error))
                }
        }
    }
    
    class func callArray<T: RequestProtocol, V where T.ResponseType == V>(request: T, completion: (Result<[V], NSError>) -> Void) {
        ApiManager.sharedInstance.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print("response array $$$$$$$$$$$$$$$$$$$")
                print(response.result.value)
                print("response array end $$$$$$$$$$$$$$$")

                switch response.result {
                case .Success(let json):
                    print("to json")
                    completion(request.fromJsonByArray(json))
                case .Failure(let error):
                    completion(.Failure(error))
                }
        }
    }
    
}