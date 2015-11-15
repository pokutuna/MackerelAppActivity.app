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
    
    var apptivityInstance: ApptivityCollector?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.apptivityInstance = ApptivityCollector.init()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

