//
//  NewListAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/17.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

class NewListAction {
    final let isLoading = Variable(false)
    final let list: Variable<List?> = Variable(nil)
    final let err: Variable<Error?> = Variable(nil)
    final let disposeBag = DisposeBag()

    func request(projectID: Int, params: [String: AnyObject]) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        err.value = nil
        FasciaAPIService.sharedInstance.call(path: "/projects/\(projectID)/lists", method: .post, params: params)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (response, data) throws -> List in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: AnyObject] else {
                    throw ListsError.parserError
                }
                guard let list = Mapper<List>().map(JSON: json) else {
                    throw ListsError.mappingError
                }
                return list
            }
            .subscribe(onNext: { (list) in
                    self.list.value = list
                }, onError: { (errorType) in
                    self.err.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil
            )
            .addDisposableTo(disposeBag)
    }
}
