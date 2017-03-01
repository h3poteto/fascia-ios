//
//  Task.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

enum TaskError: Error {
    case parserError
    case mappingError
}

class Task: Mappable {
    var id: Int?
    var listID: Int?
    var userID: Int?
    var issueNumber: Int?
    var title: String?
    var pullRequest: Bool?
    var taskDescription: String?

    required init?(map: Map) {
        mapping(map: map)
    }

    func mapping(map: Map) {
        id          <- map["ID"]
        listID      <- map["ListID"]
        userID      <- map["UserID"]
        issueNumber <- map["IssueNumber"]
        title       <- map["Title"]
        pullRequest <- map["PullRequest"]
        taskDescription <- map["Description"]
    }
}

extension Task: CustomStringConvertible {
    internal var description: String {
        return "{id:\(id), listID:\(listID), userID:\(userID), issueNumber:\(issueNumber), title:\(title), pullRequest:\(pullRequest), description:\(taskDescription)}"
    }
}
