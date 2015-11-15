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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        do {
            self.config = try ApptivityConfig.init()
        } catch {
            print(error)
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
    
    func postToMackerel() {
        let activity = self.collector!.fetchAndFlush()
        
        let epoch = Int(NSDate().timeIntervalSince1970)
        let prefix = self.config!.metricPrefix
        var metrics: Dictionary<String, Int> = [:]
        for (bundleName, keyDowns) in activity {
            let key = prefix + config!.getMappedName(bundleName)
            metrics[key] = keyDowns
        }
        
        guard metrics.count > 0 else { return }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let isSuccess = self.mackerel!.postServiceMetric(
                self.config!.serviceName,
                nameValue: metrics,
                epoch: epoch
            )
            if !isSuccess {
                dispatch_sync(dispatch_get_main_queue()) {
                    self.onFailPost(activity)
                }
            }
        }
    }
    
    func onFailPost(failedActivity: Dictionary<String,Int>) {
        print("post failed!")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

