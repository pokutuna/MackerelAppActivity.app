//
//  ApptivityCollector.swift
//  MackerelAppActivity
//
//  Created by pokutuna on 2015/11/14.
//  Copyright © 2015年 pokutuna. All rights reserved.
//

import Cocoa

class ApptivityCollector: NSObject {
    
    static let defaultAppName = "_none_"
    
    var counter: Dictionary<String, Int> = [String:Int]() // AppName:KeyDowns
    var currentAppName: String = ApptivityCollector.defaultAppName
    
    let workspace: NSWorkspace = NSWorkspace.sharedWorkspace()
    var keyDownHandler: AnyObject?

    override init() {
        super.init()
        initAppSwitch()
        initGlobalKeyDown()
    }
    
    func initAppSwitch() {
        self.workspace.notificationCenter.addObserver(
            self,
            selector: "onSwitchApp",
            name: NSWorkspaceDidActivateApplicationNotification,
            object: nil
        )
    }
    
    func onSwitchApp() {
        var appName = ApptivityCollector.defaultAppName
        if let app = self.workspace.frontmostApplication {
            if let bi = app.bundleIdentifier {
                appName = bi.characters.split(".").last.flatMap(String.init)!
            }
        }
        self.currentAppName = appName
    }
    
    func initGlobalKeyDown() {
        self.keyDownHandler = NSEvent.addGlobalMonitorForEventsMatchingMask(
            NSEventMask.KeyDownMask,
            handler: { (ev: NSEvent) in self.onKeyDown(ev) }
        )
    }
    
    func onKeyDown(event: NSEvent) {
        let appName = self.currentAppName
        if let count = self.counter[appName] {
          self.counter.updateValue(count + 1, forKey: appName)
        } else {
            self.counter[appName] = 1
        }
        print(appName + ":" + String(self.counter[appName]))
    }
    
    func fetchAndFlush() -> Dictionary<String, Int> {
        let dict = self.counter
        self.counter = [String:Int]()
        return dict
    }
    
    deinit {
        self.workspace.notificationCenter.removeObserver(self)
        if let h = self.keyDownHandler { NSEvent.removeMonitor(h) }
    }
}
