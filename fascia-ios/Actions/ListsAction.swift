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
    final let error: Variable<ErrorType?> = Variable(nil)
    final let disposeBag = DisposeBag()

    func request(projectID: Int) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        error.value = nil
        FasciaAPIService.sharedInstance.call("/projects/\(projectID)/lists", method: .GET, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (response, data) throws -> Lists in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else {
                    throw ListsError.ParserError
                }
                guard let lists = Mapper<Lists>().map(json) else {
                    throw ListsError.MappingError
                }
                return lists
            }
            .subscribe(onNext: { (lists) in
                    print(lists.lists)
                    print(lists.noneList)
                    self.lists.value = lists
                }, onError: { (errorType) in
                    self.error.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }

    func moveRequest(projectID: Int, taskID: Int, listID: Int, toListID: Int) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        error.value = nil
        let params = [
            "to_list_id": toListID,
            "prev_to_task_id": 0
        ]
        FasciaAPIService.sharedInstance.call("/projects/\(projectID)/lists/\(listID)/tasks/\(taskID)/move_task", method: .POST, params: params)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (response, data) throws -> Lists in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else {
                    throw ListsError.ParserError
                }
                guard let lists = Mapper<Lists>().map(json) else {
                    throw ListsError.MappingError
                }
                return lists
            }
            .subscribe(onNext: { (lists) in
                    print(lists.lists)
                    print(lists.noneList)
                    self.lists.value = lists
                }, onError: { (errorType) in
                    self.error.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}
