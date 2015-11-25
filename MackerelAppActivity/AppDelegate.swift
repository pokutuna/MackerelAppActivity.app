//
//  AppDelegate.swift
//  MackerelAppActivity
//
//  Created by pokutuna on 2015/11/14.
//  Copyright © 2015年 pokutuna. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var config: Config?
    var collector: KeydownCollector?
    var mackerel: MackerelClient?

    var timer: NSTimer?

    var requestErrorCount = 0
    static let thresholdCountToExit = 5

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    func initStatusItem() {
        let menu = NSMenu()
        self.statusItem.image = NSImage(named: "SabakunTemplate")
        self.statusItem.menu = menu

        let versionMenuItem = NSMenuItem()
        versionMenuItem.title = "Version: " + self.getVersion()
        menu.addItem(versionMenuItem)

        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit"
        quitMenuItem.action = Selector("quit:")
        menu.addItem(quitMenuItem)
    }

    func getVersion() -> String {
        return NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    @IBAction func quit(sender: NSButton) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.initStatusItem()

        do {
            self.config = try Config.init()
        } catch {
            self.errorAlert("Config." + String(error))
        }
        self.collector = KeydownCollector.init()
        self.mackerel  = MackerelClient.init(apiKey: self.config!.apiKey)

        self.runTimer()
    }
    
    func runTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(
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
                metrics.append([ "name": metricName, "value": keyDowns, "time": epoch ])
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
            self.onFailPost(error, failedActivity: activity)
        }
    }
    
    func onFailPost(error: ErrorType, failedActivity: Dictionary<String,Int>) {
        // hack for ignoring a offline error
        if (error as NSError).domain != "NSURLErrorDomain" {
            self.requestErrorCount += 1
            if self.requestErrorCount >= AppDelegate.thresholdCountToExit {
                self.errorAlert("Too many API error. Check key and parmaeters")
            }
        }
        
        // restore unsent metrics
        self.collector!.mergeCounter(failedActivity)
    }

    func applicationWillTerminate(aNotification: NSNotification) {}
    
    func errorAlert(message: String) {
        if self.timer?.valid != nil {
            timer!.invalidate()
        }

        let alert = NSAlert()
        alert.messageText = "Error in MackerelAppActivity"
        alert.alertStyle = NSAlertStyle.CriticalAlertStyle
        alert.informativeText = message
        alert.addButtonWithTitle("Quit")
        alert.runModal()
        self.quit(alert.buttons[0])
    }
}
