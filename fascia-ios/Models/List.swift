//
//  List.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import ObjectMapper

class List: Mappable {
    var id: Int?
    var projectID: Int?
    var userID: Int?
    var title: String?
    var color: String?
    var listOptionID: Int?
    var isHidden: Bool?
    var listTasks: Array<Task>  = []

    required init?(map: Map) {
        mapping(map: map)
    }

    func mapping(map: Map) {
        id              <- map["ID"]
        projectID       <- map["ProjectID"]
        userID          <- map["UserID"]
        title           <- map["Title"]
        color           <- map["Color"]
        listOptionID    <- map["ListOptionID"]
        isHidden        <- map["IsHidden"]
        listTasks       <- map["ListTasks"]
    }
}

extension List: CustomStringConvertible {
    internal var description: String {
        return "{id:\(String(describing: id)), projectID:\(String(describing: projectID)), userID:\(String(describing: userID)), title:\(String(describing: title)), color:\(String(describing: color)), listOptionID:\(String(describing: listOptionID)), isHidden:\(String(describing: isHidden))}"
    }
}
