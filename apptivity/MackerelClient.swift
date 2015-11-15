//
//  MackerelClient.swift
//  MackerelAppActivity
//
//  Created by pokutuna on 2015/11/15.
//  Copyright © 2015年 pokutuna. All rights reserved.
//

import Foundation
import Alamofire

class MackerelClient {
    
    static let host = "https://mackerel.io"
    var apiKey: String = ""
    
    init (apiKey: String) {
        self.apiKey = apiKey
    }
    
    func requestHeader() -> Dictionary<String, String> {
        return [ "X-Api-Key": self.apiKey, "Content-Type": "application/json" ]
    }
    
    func postServiceMetric(serviceName: String, nameValue: Dictionary<String, Int>, epoch: Int) -> Bool {
        let path = String(format: "/api/v0/services/%@/tsdb", serviceName)
        
        var metricValues: Array<Dictionary<String, AnyObject>> = []
        for (k, v) in nameValue {
            metricValues.append([ "name": k, "value": v, "time": epoch ])
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: MackerelClient.host + path)!)
        request.HTTPMethod = "POST"
        for (k,v) in self.requestHeader() {
            request.setValue(v, forHTTPHeaderField: k)
        }
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(metricValues, options: [])
        
        let response = Alamofire.request(request).validate().response
        print(response)
        return response?.statusCode == 200 ? true : false
    }


}