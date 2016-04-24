//
//  Scheduler.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/24.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift

class Scheduler {

    // MARK: - Properties

    let mainScheduler = MainScheduler.asyncInstance
    let backgroundScheduler: ImmediateSchedulerType = {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = NSQualityOfService.UserInitiated

        return OperationQueueScheduler(operationQueue: operationQueue)
    }()

    static let sharedInstance = Scheduler()

    // MARK: - Initializers

    private init() {}
    
}
