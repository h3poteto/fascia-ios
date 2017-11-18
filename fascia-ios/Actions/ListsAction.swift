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
    final let isLoading = Variable(false)
    final var lists: Variable<Lists?> = Variable(nil)
    final let err: Variable<Error?> = Variable(nil)
    private let disposeBag = DisposeBag()

    func request(projectID: Int) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        err.value = nil
        FasciaAPIService.sharedInstance.call(path: "/projects/\(projectID)/lists", method: .get, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (response, data) throws -> Lists in
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
                    self.lists.value = lists
                }, onError: { (errorType) in
                    self.err.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    func moveRequest(projectID: Int, taskID: Int, listID: Int, toListID: Int) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        err.value = nil
        let params = [
            "to_list_id": toListID,
            "prev_to_task_id": 0
        ]
        FasciaAPIService.sharedInstance.call(path: "/projects/\(projectID)/lists/\(listID)/tasks/\(taskID)/move_task", method: .post, params: params as [String : AnyObject]?)
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
                    self.lists.value = lists
                }, onError: { (errorType) in
                    self.err.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
