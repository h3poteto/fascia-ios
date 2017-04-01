//
//  ListOption.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/28.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

enum ListOptionError: Error {
    case mappingError
    case parserError
}

class ListOption: Mappable {
    var id: Int?
    var action: String?

    class func buildWithArray(listOptions: [[String: AnyObject]]) -> [ListOption] {
        var arr: [ListOption] = []
        for dict in listOptions {
            if let listOption = Mapper<ListOption>().map(JSON: dict) {
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

    required init?(map: Map) {
        mapping(map: map)
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
        return "{id: \(String(describing: id)), action: \(String(describing: action))}"
    }
}
