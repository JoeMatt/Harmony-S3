//
//  Professor.swift
//  HarmonyTests
//
//  Created by Joseph Mattiello on 10/21/17.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import CoreData
import Foundation

import Harmony

@objc(Professor)
public class Professor: NSManagedObject {}

extension Professor: Syncable {
    public class var syncablePrimaryKey: AnyKeyPath {
        \Professor.identifier
    }

    public var syncableKeys: Set<AnyKeyPath> {
        [\Professor.name]
    }
}
