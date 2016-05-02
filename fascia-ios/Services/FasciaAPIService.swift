//
//  FasciaAPIService.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/21.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxAlamofire
import Alamofire
import RxSwift
import RxCocoa

enum FasciaAPIError: ErrorType {
    case AuthenticateError
    case ClientError
    case ServerError
    case DoubleRequestError
}

class FasciaAPIService {
    static let sharedInstance = FasciaAPIService()
#if DEBUG
    let APIHost = "http://fascia.localdomain:9090"
#else
    let APIHost = "https://fascia.io"
#endif
    private var manager: Manager
    private let disposeBag = DisposeBag()
    private static let CookieKey = "fascia-session"

    init() {
        manager = FasciaAPIService.configureManager()
    }

    func call(path: String, method: Alamofire.Method, params: [String: AnyObject]?) -> Observable<(NSHTTPURLResponse, NSData)> {
        return manager.rx_responseData(method, NSURL(string: APIHost + path)!, parameters: params, encoding: .URL, headers: nil)
            .observeOn(MainScheduler.instance)
            .map({ (response, json) -> (NSHTTPURLResponse, NSData) in
                switch response.statusCode {
                case 401:
                    throw FasciaAPIError.AuthenticateError
                case 401..<500:
                    throw FasciaAPIError.ClientError
                case 500..<600:
                    throw FasciaAPIError.ServerError
                default:
                    break
                }
                return (response, json)
            })
    }

    func saveSession(response: NSHTTPURLResponse) {
        let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(response.allHeaderFields as! [String:String], forURL: (response.URL)!)
        for i in 0 ..< cookies.count {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookies[i])
        }
        let cookiesData: NSData = NSKeyedArchiver.archivedDataWithRootObject(NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!)
        NSUserDefaults.standardUserDefaults().setObject(cookiesData, forKey: FasciaAPIService.CookieKey)
    }

    private class func configureManager() -> Manager {
        if let cookiesData = NSUserDefaults.standardUserDefaults().objectForKey(CookieKey) as? NSData {
            for cookie: NSHTTPCookie in NSKeyedUnarchiver.unarchiveObjectWithData(cookiesData) as! [NSHTTPCookie] {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
            }
        }
        let cfg = NSURLSessionConfiguration.defaultSessionConfiguration()
        cfg.HTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        cfg.timeoutIntervalForResource = 30
        cfg.timeoutIntervalForRequest = 10
        return Manager(configuration: cfg)
    }
}
