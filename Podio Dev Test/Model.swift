//
//  Model.swift
//  Podio Dev Test
//
//  Created by Karlo Kristensen on 17/11/14.
//  Copyright (c) 2014 floskel. All rights reserved.
//

import UIKit

struct Organization : Printable {
    internal let name:String
    internal var spaces:[Space] = []
    
    init(name:String) {
        self.name = name
    }
    
    var description:String {
        return "Organization: \(name)"
    }
}

struct Space : Printable {
    internal let name:String
    internal let organization:Organization
    
    var description:String {
        return "Space: \(name)"
    }
}

class ModelParser: NSObject {
    func parseOrganization(object:JSONObject) -> Organization {
        let name = object["name"] as String
        var organization = Organization(name: name)
        
        let spaceObjects = object["spaces"] as JSONArray
        for spaceObject in spaceObjects {
            let space = parseSpace(spaceObject, organization: organization)
            organization.spaces.append(space)
        }
        return organization
    }
    
    func parseSpace(object:JSONObject, organization:Organization) -> Space {
        let spaceName = object["name"] as String
        let space = Space(name: spaceName, organization:organization)
        return space
    }
}
