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
            return Observable.error(FasciaAPIError.DoubleRequestError)
        }
        fetching = true
        return FasciaAPIService.sharedInstance.callBasicAPI("/projects", method: .GET, params: nil)
            .map({ (data, response) -> [Project] in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [[String: AnyObject]] else {
                    fatalError("parse error")
                }
                self.projects = Project.buildWithArray(json)
                return self.projects
            }).doOn({ (event) in
                self.fetching = false
            })
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)

    }
}
