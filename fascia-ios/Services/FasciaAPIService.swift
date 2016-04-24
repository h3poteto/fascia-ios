//
//  FasciaAPIService.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/21.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import Alamofire

class FasciaAPIService: NSObject {
    static let sharedInstance = FasciaAPIService()
    private var manager: Alamofire.Manager?
    private let CookieKey = "fascia-session"

#if DEBUG
    let APIHost = "http://fascia.localdomain:9090"
#else
    let APIHost = "https://fascia.io"
#endif
    

    private override init() {
        super.init()
    }

    private func configureManager() -> Alamofire.Manager? {
        if manager == nil {
            if let cookiesData = NSUserDefaults.standardUserDefaults().objectForKey(CookieKey) as? NSData {
                for cookie: NSHTTPCookie in NSKeyedUnarchiver.unarchiveObjectWithData(cookiesData) as! [NSHTTPCookie] {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
                }
            }
            let cfg = NSURLSessionConfiguration.defaultSessionConfiguration()
            cfg.HTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            manager = Alamofire.Manager(configuration: cfg)
        }
        return manager
    }

    func hasCookie() -> Bool {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(CookieKey) as? NSData {
            return true
        }
        return false
    }

    func callBasicAPI(
        path: String,
        method: Alamofire.Method,
        params: [String: AnyObject]?,
        success: (AnyObject) -> Void,
        failure: (NSError) -> Void
        ) {

        configureManager()?.request(method, APIHost + path, parameters: params, encoding: .JSON, headers: nil).responseJSON(completionHandler: { (response) in
            if response.response?.statusCode == 200 || response.response?.statusCode == 201 {
                success((response as? AnyObject)!)
            } else {
                failure(response.result.error!)
            }
        })

    }

    func updateSession() {
        callBasicAPI("/session", method: .POST, params: nil, success: { (response) in
            if let res = response as? Response<AnyObject, NSError> {
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(res.response?.allHeaderFields as! [String:String], forURL: (res.response?.URL)!)
                for i in 0 ..< cookies.count {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookies[i])
                }
                let cookiesData: NSData = NSKeyedArchiver.archivedDataWithRootObject(NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!)
                NSUserDefaults.standardUserDefaults().setObject(cookiesData, forKey: self.CookieKey)
            }
            }) { (error) in
        }
    }

}
