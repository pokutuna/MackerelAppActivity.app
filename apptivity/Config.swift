//
//  Config.swift
//  MackerelAppActivity
//
//  Created by pokutuna on 2015/11/15.
//  Copyright © 2015年 pokutuna. All rights reserved.
//

import Foundation
import SwiftyJSON

extension String {
    func isSafeNameForAppActivity() -> Bool {
        // bundleIdentifier -> metric name([a-zA-Z0-9._-]+)
        if self.isEmpty { return false }
        if self.rangeOfString(" ") != nil { return false }
        
        let regex = try! NSRegularExpression(
            pattern: "^[a-zA-Z0-9._-]+$",
            options: [.CaseInsensitive]
        )
        return regex.firstMatchInString(
            self,
            options: [],
            range: NSMakeRange(0, self.characters.count)) != nil
    }
}

class ApptivityConfig {

    static let configFileName = ".mackerel-app-activity.json" // TODO to plist
    static let requiredKeys = ["ApiKey", "ServiceName", "MetricPrefix"]
    static let defaultPostIntervalMinutes = 1
    
    var configJson: JSON = nil
    var apiKey: String {
        get { return self.configJson["ApiKey"].stringValue }
    }
    var serviceName: String {
        get { return self.configJson["ServiceName"].stringValue }
    }
    var metricPrefix: String {
        get { return self.configJson["MetricPrefix"].stringValue }
    }
    var postIntervalMinutes: Int {
        get {
            let num = self.configJson["PostIntervalMinutes"].number
            return num != nil ? Int(num!) : ApptivityConfig.defaultPostIntervalMinutes
        }
    }
    var nameMapping: Dictionary<String,JSON> {
        get { return self.configJson["NameMapping"].dictionaryValue }
    }

    enum Error: ErrorType {
        case FileNotExist
        case FileCannotParse
        case RequiredParameterInsufficient(message: String)
        case NameMappingError(message: String)
    }
    
    init () throws {
        let path = (NSHomeDirectory() as NSString)
            .stringByAppendingPathComponent(ApptivityConfig.configFileName)
        guard NSFileManager.defaultManager().fileExistsAtPath(path) else {
            throw Error.FileNotExist
        }
        
        let data = NSFileHandle(forReadingAtPath: path)?.readDataToEndOfFile()
        guard data != nil else { throw Error.FileCannotParse }
        
        let json = JSON(data: data!)
        guard json != nil else { throw Error.FileCannotParse }
        try self.validateJson(json)
        
        self.configJson = json
    }
    
    func validateJson(config: JSON) throws {
        // required keys
        for key in ApptivityConfig.requiredKeys {
            guard let _ = config[key].string else {
                throw Error.RequiredParameterInsufficient(message: key) 
            }
        }
        
        // NameMapping values are must be acceptable to mackerel metric
        let mapping: Dictionary<String,JSON> = config["NameMapping"].dictionaryValue;
        for (key, value) in mapping {
            guard value.stringValue.isSafeNameForAppActivity() != false else {
                let valueStr = value.string ?? "undefined or not a String"
                throw Error.NameMappingError(message: key + ":" + valueStr)
            }
        }
    }
    
    func getMappedName(bundleName: String) -> String {
        if let name = self.nameMapping[bundleName] {
            return name.stringValue
        } else {
            return bundleName
        }
    }
}