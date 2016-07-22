//
//  OAuthViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/25.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class OAuthViewController: UIViewController, UIWebViewDelegate {
    
    let redirectScheme : String = "ioshavings"
    
    @IBOutlet weak var OAuthWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        OAuthWebView.delegate = self
        if let url = NSURL(string: "https://havings.com:9292/users/auth/twitter?origin=ios") {
            let urlRequest = NSURLRequest(URL: url)
            NSURLConnection(request: urlRequest, delegate: self)!

            OAuthWebView.loadRequest(urlRequest)
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signin(token t : String, uid u : String, userId ui: String){
        let tokenManager = TokenManager.sharedManager
        tokenManager.saveTokenAndUid(token: t, uid: u, userId: Int(ui)!)
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        if let next :UIViewController = storyboard.instantiateInitialViewController() {
            self.presentViewController(next, animated: true, completion: nil)
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = NSURL(string: request.URLString) {
            if url.scheme == redirectScheme {
                let comp: NSURLComponents? = NSURLComponents(string: request.URLString)
                let fragments = generateDictionalyFromUrlComponents(comp!)
                print("aaaaaa")
                print(fragments)
                if let token = fragments["token"], let uid = fragments["uid"], let userId = fragments["userid"] {
                    
                    signin(token: token, uid: uid, userId: userId)
                    return false
                }
            }

        }
        
        // http://blog.ch3cooh.jp/entry/20130208/1360299071
        return true
    }
    
    // http://fromatom.hatenablog.com/entry/2015/10/27/125622
    func generateDictionalyFromUrlComponents(components: NSURLComponents) -> [String : String] {
        var fragments: [String : String] = [:]
        guard let items = components.queryItems else {
            return fragments
        }
        
        for item in items {
            fragments[item.name] = item.value
        }
        
        return fragments
    }
    
    func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool{
        print("canAuthenticateAgainstProtectionSpace method Returning True")
        return true
    }
    
    
    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge){
        
        print("did autherntcationchallenge = \(challenge.protectionSpace.authenticationMethod)")
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust  {
            print("send credential Server Trust")
            let credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
            challenge.sender!.useCredential(credential, forAuthenticationChallenge: challenge)
            
        }else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic{
            print("send credential HTTP Basic")
            let defaultCredentials: NSURLCredential = NSURLCredential(user: "username", password: "password", persistence:NSURLCredentialPersistence.ForSession)
            challenge.sender!.useCredential(defaultCredentials, forAuthenticationChallenge: challenge)
            
        }else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM{
            print("send credential NTLM")
            
        } else{
            challenge.sender!.performDefaultHandlingForAuthenticationChallenge!(challenge)
        }
    }
    

}
