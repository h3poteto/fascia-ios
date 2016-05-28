//
//  ListOptionsAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/28.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class ListOptionsAction {
    final let isLoading = Variable(false)
    final let listOptions = Variable([ListOption]())
    final let error: Variable<ErrorType?> = Variable(nil)
    final let disposeBag = DisposeBag()

    func request() {
        if isLoading.value {
            return
        }
        isLoading.value = false
        error.value = nil
        FasciaAPIService.sharedInstance.call("/list_options", method: .GET, params: nil)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .map { (response, data) throws -> [ListOption] in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [[String: AnyObject]] else {
                    throw ListOptionError.ParserError
                }
                return ListOption.buildWithArray(json)
            }
            .subscribe(onNext: { (listOptions) -> Void in
                print(listOptions)
                self.listOptions.value = listOptions
                }, onError: { (errorType) in
                    self.error.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil)
            .addDisposableTo(self.disposeBag)
    }
}
