//
//  PodioApi.swift
//  Podio Dev Test
//
//  Created by Karlo Kristensen on 17/11/14.
//  Copyright (c) 2014 floskel. All rights reserved.
//

import UIKit

typealias JSONObject = Dictionary<String, AnyObject>
typealias JSONArray = Array<JSONObject>

typealias AuthCompletion = (success:Bool) -> Void
typealias OrganizationCompletion = (success:Bool, organizations:[Organization]) -> Void

struct HTTPMethod {
    static let POST = "POST"
    static let GET = "GET"
}

class PodioApi: NSObject {
    private let session:NSURLSession
    private let baseUrl = NSURL(string: "https://api.podio.com")
    
    private let apiKey = "karlo-podio-test"
    private let apiSecret = "20Q67x9ljXTLp6DtksioXM5LxKWDkNJoOxwl28AHB61f5NekLvZ743JqeErApetQ"
    
    private var accessToken:String?
    
    internal var isLoggedIn:Bool {
        get {
            let result = ((self.accessToken?.isEmpty) != nil)
            return result
        }
    }
    
    internal class var sharedInstance : PodioApi {
        struct Singleton {
            static let instance = PodioApi()
        }
        return Singleton.instance
    }
    
    private override init() {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: sessionConfig)
        super.init()
    }
    
    internal func login(username:String, password:String, completion:AuthCompletion) {
        let authUrl = NSURL(string: "oauth/token", relativeToURL: baseUrl)!
        
        let body = "grant_type=password&username=\(username)&password=\(password)&client_id=\(apiKey)&client_secret=\(apiSecret)"
     
        let request = NSMutableURLRequest(URL: authUrl)
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPMethod = HTTPMethod.POST
        
        session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            
            var success = false
            if error == nil {
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        var jsonResult: JSONObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as JSONObject
                        self.accessToken = jsonResult["access_token"] as? String
                        success = true
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(success: success)
            })
        }).resume()
    }
    
    internal func getOrganizations(completion:OrganizationCompletion) {
        if let accessToken = self.accessToken {
            
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfig.HTTPAdditionalHeaders = ["Authorization" : "OAuth2 \(accessToken)" ]
            
            let authenticatedSession = NSURLSession(configuration: sessionConfig)
            
            let orgUrl = NSURL(string: "org/", relativeToURL: baseUrl)!
            
            authenticatedSession.dataTaskWithURL(orgUrl, completionHandler: {
                data, response, error in
                
                var organizations:[Organization] = []
                var success = false
                if error == nil {
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            var jsonResult: JSONArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as JSONArray
                            let parser = ModelParser()
                            for object in jsonResult {
                                let org = parser.parseOrganization(object)
                                organizations.append(org)
                            }
                            success = true
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(success: success, organizations: organizations)
                })
            }).resume()
        }
    }

}
