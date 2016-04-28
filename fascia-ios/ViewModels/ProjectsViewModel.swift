//
//  ProjectsViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/24.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class ProjectsViewModel: NSObject {
    var projects: [Project] = []
    private let disposeBag = DisposeBag()
    private var fetching = false

    func existSession() -> Bool {
        return FasciaAPIService.sharedInstance.hasCookie()
    }

    func fetch() -> Observable<[Project]> {
        if fetching {
            return Observable.never()
        }
        fetching = true
        return FasciaAPIService.sharedInstance.callBasicAPI("/projects", method: .GET, params: nil)
            .doOnNext({ (data, response) in
                if response.statusCode == 401 {
                    print("authenticate error")
                }
            })
            .map({ (data, response) -> [Project] in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [[String: AnyObject]] else {
                    fatalError("parse error")
                }
                self.projects = Project.buildWithArray(json)
                return self.projects
            })
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)

    }
}
