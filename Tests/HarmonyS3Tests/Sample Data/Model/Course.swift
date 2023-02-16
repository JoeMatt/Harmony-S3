//
//  Course.swift
//  HarmonyTests
//
//  Created by Joseph Mattiello on 10/21/17.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import CoreData
import Foundation

import Harmony

@objc(Course)
public class Course: NSManagedObject {}

extension Course: Syncable {
    public class var syncablePrimaryKey: AnyKeyPath {
        \Course.identifier
    }

    public var syncableKeys: Set<AnyKeyPath> {
        [\Course.name]
    }
}
