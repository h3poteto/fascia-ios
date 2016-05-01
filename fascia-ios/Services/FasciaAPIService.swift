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
    #if DEBUG
    let APIHost = "http://fascia.localdomain:9090"
    #else
    let APIHost = "https://fascia.io"
    #endif
    let manager = Manager.sharedInstance
    let disposeBag = DisposeBag()

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
}
