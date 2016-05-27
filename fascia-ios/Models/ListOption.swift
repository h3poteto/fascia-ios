//
//  ListOption.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/28.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

enum ListOptionError: ErrorType {
    case MappingError
    case ParserError
}

class ListOption: Mappable {
    var id: Int?
    var action: String?

    class func buildWithArray(listOptions: [[String: AnyObject]]) -> [ListOption] {
        var arr: [ListOption] = []
        for dict in listOptions {
            if let listOption = Mapper<ListOption>().map(dict) {
                arr.append(listOption)
            }
        }
        return arr
    }

    class func findAction(listOptions: [ListOption], id: Int) -> ListOption? {
        var option: ListOption?
        for o in listOptions {
            if o.id != nil && o.id == id {
                option = o
            }
        }
        return option
    }

    required init?(_ map: Map) {
        mapping(map)
    }

    init() {
    }

    func mapping(map: Map) {
        id <- map["ID"]
        action <- map["Action"]
    }
}

extension ListOption: CustomStringConvertible {
    var description: String {
        return "{id: \(id), action: \(action)}"
    }
}
