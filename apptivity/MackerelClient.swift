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

    func postServiceMetric(serviceName: String, metrics: Array<Dictionary<String, AnyObject>>, onError: ((ErrorType) -> Void)?) {
        let path = String(format: "/api/v0/services/%@/tsdb", serviceName)
        let request = NSMutableURLRequest(URL: NSURL(string: MackerelClient.host + path)!)
        request.HTTPMethod = "POST"
        for (k,v) in self.requestHeader() {
            request.setValue(v, forHTTPHeaderField: k)
        }

        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(metrics, options: [])

        Alamofire.request(request)
            .validate()
            .responseJSON { res in
                switch res.result {
                case .Failure(let error): onError?(error)
                default: break
                }
            }
    }
}