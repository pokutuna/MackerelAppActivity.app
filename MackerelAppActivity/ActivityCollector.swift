//
//  KeydownCollector.swift
//  MackerelAppActivity
//
//  Created by pokutuna on 2015/11/14.
//  Copyright © 2015年 pokutuna. All rights reserved.
//

import Cocoa

class KeydownCollector: NSObject {

    static let defaultBundleName = "_none_"

    var counter: Dictionary<String, Int> = [String:Int]() // BundleName:KeyDowns
    var currentBundleName: String = KeydownCollector.defaultBundleName

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
        var bundleName = KeydownCollector.defaultBundleName
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
    }

    func fetchAndFlush() -> Dictionary<String, Int> {
        let dict = self.counter
        for (k) in self.counter.keys {
            self.counter.updateValue(0, forKey: k)
        }
        return dict
    }

    // for restore
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
