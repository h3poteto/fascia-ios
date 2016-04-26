//
//  FasciaAPIService.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/21.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import Alamofire
import RxSwift
import RxCocoa

class FasciaAPIService: NSObject {
    static let sharedInstance = FasciaAPIService()
    private var manager: Alamofire.Manager?
    private let CookieKey = "fascia-session"
    private let disposeBag = DisposeBag()

#if DEBUG
    let APIHost = "http://fascia.localdomain:9090"
#else
    let APIHost = "https://fascia.io"
#endif
    

    private override init() {
        super.init()
    }

    private func configureManager() -> Alamofire.Manager {
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
        return manager!
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
        params: [String: AnyObject]?) -> Observable<AnyObject> {

        let request = configureManager().request(method, APIHost + path, parameters: params, encoding: .JSON, headers: nil).request
        if let request = request {
            return configureManager().session.rx_JSON(request)
        } else {
            fatalError("Invalid Request")
        }

    }

    func updateSession() {
        let request = configureManager().request(.POST, APIHost + "/session", parameters: nil, encoding: .JSON, headers: nil).request
        if let request = request {
            configureManager().session.rx_response(request)
                .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
                .observeOn(Scheduler.sharedInstance.mainScheduler)
                .subscribeNext({ (data, response) -> Void in
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(response.allHeaderFields as! [String:String], forURL: (response.URL)!)
                    for i in 0 ..< cookies.count {
                        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookies[i])
                    }
                    let cookiesData: NSData = NSKeyedArchiver.archivedDataWithRootObject(NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!)
                    NSUserDefaults.standardUserDefaults().setObject(cookiesData, forKey: self.CookieKey)
                })
                .addDisposableTo(disposeBag)
        }
    }

}
