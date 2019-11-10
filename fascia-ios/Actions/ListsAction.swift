//
//  ListsAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

class ListsAction {
    final let isLoading = BehaviorRelay(value: false)
    final var lists: BehaviorRelay<Lists?> = BehaviorRelay(value: nil)
    final let err: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()

    func request(projectID: Int) {
        if isLoading.value {
            return
        }
        isLoading.accept(true)
        err.accept(nil)
        FasciaAPIService.sharedInstance.call(path: "/api/projects/\(projectID)/lists", method: .get, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (_, data) throws -> Lists in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: AnyObject] else {
                    throw ListsError.parserError
                }
                guard let lists = Mapper<Lists>().map(JSON: json) else {
                    throw ListsError.mappingError
                }
                return lists
            }
            .subscribe(onNext: { (lists) in
                print(lists.lists)
                print(lists.noneList ?? "")
                self.lists.accept(lists)
            }, onError: { (errorType) in
                self.err.accept(errorType)
                self.isLoading.accept(false)
            }, onCompleted: {
                self.isLoading.accept(false)
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    func moveRequest(projectID: Int, taskID: Int, listID: Int, toListID: Int) {
        if isLoading.value {
            return
        }
        isLoading.accept(true)
        err.accept(nil)
        let params = [
            "to_list_id": toListID,
            "prev_to_task_id": 0
        ]
        FasciaAPIService.sharedInstance.call(path: "/api/projects/\(projectID)/lists/\(listID)/tasks/\(taskID)/move_task", method: .post, params: params as [String : AnyObject]?)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (_, data) throws -> Lists in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: AnyObject] else {
                    throw ListsError.parserError
                }
                guard let lists = Mapper<Lists>().map(JSON: json) else {
                    throw ListsError.mappingError
                }
                return lists
            }
            .subscribe(onNext: { (lists) in
                print(lists.lists)
                print(lists.noneList ?? "")
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
