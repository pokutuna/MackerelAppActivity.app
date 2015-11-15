//
//  ApptivityCollector.swift
//  MackerelAppActivity
//
//  Created by pokutuna on 2015/11/14.
//  Copyright © 2015年 pokutuna. All rights reserved.
//

import Cocoa

class ApptivityCollector: NSObject {
    
    static let defaultBundleName = "_none_"
    
    var counter: Dictionary<String, Int> = [String:Int]() // BundleName:KeyDowns
    var currentBundleName: String = ApptivityCollector.defaultBundleName
    
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
        var bundleName = ApptivityCollector.defaultBundleName
        if let app = self.workspace.frontmostApplication {
            if let bi = app.bundleIdentifier {
                bundleName = bi.characters.split(".").last.flatMap(String.init)!
            }
        }
        self.currentBundleName = bundleName
    }
    
    func initGlobalKeyDown() {
        self.keyDownHandler = NSEvent.addGlobalMonitorForEventsMatchingMask(
            NSEventMask.KeyDownMask,
            handler: { (ev: NSEvent) in self.onKeyDown(ev) }
        )
    }
    
    func onKeyDown(event: NSEvent) {
        let bundleName = self.currentBundleName
        if let count = self.counter[bundleName] {
          self.counter.updateValue(count + 1, forKey: bundleName)
        } else {
            self.counter[bundleName] = 1
        }
        print(bundleName + ":" + String(self.counter[bundleName]))
    }
    
    func fetchAndFlush() -> Dictionary<String, Int> {
        let dict = self.counter
        self.counter = [String:Int]()
        print("fetche & flush")
        return dict
    }
    
    func mergeCounter(dict: Dictionary<String, Int>) {
        for (k, v) in dict {
            if let keyDowns = self.counter[k] {
                self.counter.updateValue(keyDowns + v, forKey: k)
            } else {
                self.counter[k] = v
            }
        }
    }
    
    deinit {
        self.workspace.notificationCenter.removeObserver(self)
        if let h = self.keyDownHandler { NSEvent.removeMonitor(h) }
    }
}
