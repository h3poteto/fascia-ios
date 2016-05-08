//
//  ListVisibleAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/08.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

class ListVisibleAction {
    final let isLoading = Variable(false)
    final var lists: Variable<Lists?> = Variable(nil)
    final let error: Variable<ErrorType?> = Variable(nil)
    final let disposeBag = DisposeBag()

    func hide(list: List) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        error.value = nil
        FasciaAPIService.sharedInstance.call("/projects/\(list.projectID!)/lists/\(list.id!)/hide", method: .POST, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (response, data) -> Lists in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else {
                    throw ListsError.ParserError
                }
                guard let lists = Mapper<Lists>().map(json) else {
                    throw ListsError.MappingError
                }
                return lists
            }
            .subscribe(onNext: { (lists) in
                    self.lists.value = lists
                }, onError: { (errorType) in
                    self.error.value = errorType
                    self.isLoading.value = false
                }, onCompleted: { 
                    self.isLoading.value = false
                }, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }

    func display(list: List) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        error.value = nil
        FasciaAPIService.sharedInstance.call("/projects/\(list.projectID!)/lists/\(list.id!)/display", method: .POST, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (response, data) -> Lists in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else {
                    throw ListsError.ParserError
                }
                guard let lists = Mapper<Lists>().map(json) else {
                    throw ListsError.MappingError
                }
                return lists
            }
            .subscribe(onNext: { (lists) in
                    self.lists.value = lists
                }, onError: { (errorType) in
                    self.error.value = errorType
                    self.isLoading.value = false
                }, onCompleted: { 
                    self.isLoading.value = false
                }, onDisposed: nil
            )
            .addDisposableTo(disposeBag)
    }
}