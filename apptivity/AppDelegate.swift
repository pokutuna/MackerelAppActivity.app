//
//  AppDelegate.swift
//  MackerelAppActivity
//
//  Created by pokutuna on 2015/11/14.
//  Copyright © 2015年 pokutuna. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var config: ApptivityConfig?
    var collector: ApptivityCollector?
    var mackerel: MackerelClient?
    
    var requestErrorCount = 0

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        do {
            self.config = try ApptivityConfig.init()
        } catch {
            print(error) // TODO show error & exit application
        }
        self.collector = ApptivityCollector.init()
        self.mackerel  = MackerelClient.init(apiKey: self.config!.apiKey)
        self.runTimer()
    }
    
    func runTimer() {
        NSTimer.scheduledTimerWithTimeInterval(
            Double(self.config!.postIntervalMinutes * 60),
            target: self,
            selector: "postToMackerel",
            userInfo: nil,
            repeats: true
        )
    }
    
    func activityCounterToMackerelMetrics(activity: Dictionary<String, Int>, epoch: Int) -> Array<Dictionary<String,AnyObject>> {
        var metrics: Array<Dictionary<String, AnyObject>> = []
        for (bundleName, keyDowns) in activity {
            let metricAppName = self.config!.getMappedName(bundleName)
            
            // when a metric name is empty, it will not be sent
            if !metricAppName.isEmpty {
                let metricName: String = self.config!.metricPrefix + metricAppName
                metrics.append([ "name:": metricName, "value": keyDowns, "time": epoch ])
            }
        }
        return metrics
    }
    
    func postToMackerel() {
        let activity = self.collector!.fetchAndFlush()
        let nowEpoch = Int(NSDate().timeIntervalSince1970)
        let metrics = self.activityCounterToMackerelMetrics(activity, epoch: nowEpoch)
        guard metrics.count > 0 else { return }
        
        self.mackerel!.postServiceMetric(self.config!.serviceName, metrics: metrics) { error in
            // hack for ignoring a offline error
            if (error as NSError).domain != "NSURLErrorDomain" {
                self.requestErrorCount += 1
            }
            self.onFailPost(activity)
        }
    }
    
    func onFailPost(failedActivity: Dictionary<String,Int>) {
        self.collector!.mergeCounter(failedActivity)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

