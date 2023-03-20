//
//  AppDelegate.swift
//  HarmonyS3Example
//
//  Created by Joseph Mattiello on 2/16/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import Harmony
import HarmonyS3
import HarmonyExample
import HarmonyTestData
import os.log

#if canImport(UIKit)
import RoxasUIKit
import UIKit

@UIApplicationMain
final class S3AppDelegate: HarmonyExample.AppDelegate {
	override public func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		ServiceManager.shared.services.append(S3Service.shared)
		return super.application(application, didFinishLaunchingWithOptions: options)
	}
}
#elseif canImport(AppKit)
import AppKit

@NSApplicationMain
final class S3AppDelegate: HarmonyExample.AppDelegate {
	override func applicationDidFinishLaunching(_ notification: Notification) {
		ServiceManager.shared.services.append(S3Service.shared)
		super.applicationDidFinishLaunching(notification)
	}
}
#else
#error("Unsupported platform")
#endif
