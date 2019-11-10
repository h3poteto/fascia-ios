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
    final let isLoading = BehaviorRelay(value: false)
    final var lists: BehaviorRelay<Lists?> = BehaviorRelay(value: nil)
    final let err: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()

    func hide(list: List) {
        if isLoading.value {
            return
        }
        isLoading.accept(true)
        err.accept(nil)
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
                self.lists.accept(lists)

            }, onError: { (errorType) in
                self.err.accept(errorType)
                self.isLoading.accept(false)
            }, onCompleted: {
                self.isLoading.accept(false)
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    func display(list: List) {
        if isLoading.value {
            return
        }
        isLoading.accept(true)
        err.accept(nil)
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
                self.lists.accept(lists)
            }, onError: { (errorType) in
                self.err.accept(errorType)
                self.isLoading.accept(false)
            }, onCompleted: {
                self.isLoading.accept(false)
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
