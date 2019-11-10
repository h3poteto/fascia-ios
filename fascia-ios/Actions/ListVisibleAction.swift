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
    final let err: Variable<Error?> = Variable(nil)
    private let disposeBag = DisposeBag()

    func hide(list: List) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        err.value = nil
        FasciaAPIService.sharedInstance.call(path: "/api/projects/\(list.projectID!)/lists/\(list.id!)/hide", method: .patch, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (_, data) -> Lists in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: AnyObject] else {
                    throw ListsError.parserError
                }
                guard let lists = Mapper<Lists>().map(JSON: json) else {
                    throw ListsError.mappingError
                }
                return lists
            }
            .subscribe(onNext: { (lists) in
                    self.lists.value = lists
                }, onError: { (errorType) in
                    self.err.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    func display(list: List) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        err.value = nil
        FasciaAPIService.sharedInstance.call(path: "/api/projects/\(list.projectID!)/lists/\(list.id!)/display", method: .patch, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (_, data) -> Lists in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: AnyObject] else {
                    throw ListsError.parserError
                }
                guard let lists = Mapper<Lists>().map(JSON: json) else {
                    throw ListsError.mappingError
                }
                return lists
            }
            .subscribe(onNext: { (lists) in
                    self.lists.value = lists
                }, onError: { (errorType) in
                    self.err.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil
            )
            .disposed(by: disposeBag)
    }
}
