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

enum FasciaAPIError: Error {
    case authenticateError
    case clientError
    case serverError
    case doubleRequestError
}

class FasciaAPIService {
    static let sharedInstance = FasciaAPIService()
#if DEBUG
    let APIHost = "http://fascia.localdomain:9090"
#else
    let APIHost = "https://fascia.io"
#endif
    private var manager: SessionManager
    private let disposeBag = DisposeBag()
    private static let CookieKey = "fascia-session"
    let signInURL: String?
    let contactURL: String?

    init() {
        manager = FasciaAPIService.configureManager()
        signInURL = APIHost + "/webviews/sign_in"
        contactURL = APIHost + "/webviews/inquiries/new"
    }

    func call(path: String, method: HTTPMethod, params: [String: AnyObject]?) -> Observable<(HTTPURLResponse, NSData)> {
        return manager.rx.responseData(method, URL(string: APIHost + path)!, parameters: params, encoding: URLEncoding.default, headers: nil)
            .observeOn(MainScheduler.instance)
            .map({ (response, json) -> (HTTPURLResponse, NSData) in
                switch response.statusCode {
                case 401:
                    throw FasciaAPIError.authenticateError
                case 401..<500:
                    throw FasciaAPIError.clientError
                case 500..<600:
                    throw FasciaAPIError.serverError
                default:
                    break
                }
                return (response, json as NSData)
            })
    }

    func saveSession(response: HTTPURLResponse) {
        guard let headers = response.allHeaderFields as? [String:String] else {
            return
        }
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: (response.url)!)
        for i in 0 ..< cookies.count {
            HTTPCookieStorage.shared.setCookie(cookies[i])
        }
        let cookiesData: NSData = NSKeyedArchiver.archivedData(withRootObject: HTTPCookieStorage.shared.cookies!) as NSData
        UserDefaults.standard.set(cookiesData, forKey: FasciaAPIService.CookieKey)
    }

    func deleteSession(response: HTTPURLResponse) {
        guard let headers = response.allHeaderFields as? [String:String] else {
            return
        }
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: (response.url)!)
        for cookie in cookies {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        UserDefaults.standard.removeObject(forKey: FasciaAPIService.CookieKey)
    }

    private class func configureManager() -> SessionManager {
        if let cookiesData = UserDefaults.standard.object(forKey: CookieKey) as? NSData {
            if let cookies = NSKeyedUnarchiver.unarchiveObject(with: cookiesData as Data) as? [HTTPCookie] {
                for cookie: HTTPCookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
        }
        let cfg = URLSessionConfiguration.default
        cfg.httpCookieStorage = HTTPCookieStorage.shared
        cfg.timeoutIntervalForResource = 30
        cfg.timeoutIntervalForRequest = 10
        return SessionManager(configuration: cfg)
    }
}
