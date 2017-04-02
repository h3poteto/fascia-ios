//
//  Task.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper
import Down

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
    var taskMarkedDescription: NSAttributedString?

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

    func parseMarkdown() {
        self.taskMarkedDescription = marked(str: self.taskDescription)
    }

    private func marked(str: String?) -> NSAttributedString? {
        guard let str = str else {
            return nil
        }
        let down = Down(markdownString: str)
        let attributedString = try? down.toAttributedString(DownOptions.HardBreaks)
        guard let attr = attributedString else {
            return nil
        }
        return attr
    }
}

extension Task: CustomStringConvertible {
    internal var description: String {
        return "{id:\(String(describing: id)), listID:\(String(describing: listID)), userID:\(String(describing: userID)), issueNumber:\(String(describing: issueNumber)), title:\(String(describing: title)), pullRequest:\(String(describing: pullRequest)), description:\(String(describing: taskDescription))}"
    }
}
