//
//  Task.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper
import MMMarkdown

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
        guard let htmlString = try? MMMarkdown.htmlString(withMarkdown: str, extensions: MMMarkdownExtensions.gitHubFlavored) else {
            return nil
        }
        guard let data = htmlString.data(using: String.Encoding.unicode) else {
            return nil
        }
        let attribute = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        guard let attributeText = try? NSAttributedString(data: data, options: attribute, documentAttributes: nil) else {
            return nil
        }
        return attributeText
    }
}

extension Task: CustomStringConvertible {
    internal var description: String {
        return "{id:\(id), listID:\(listID), userID:\(userID), issueNumber:\(issueNumber), title:\(title), pullRequest:\(pullRequest), description:\(taskDescription)}"
    }
}
