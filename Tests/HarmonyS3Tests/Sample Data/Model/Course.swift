//
//  Course.swift
//  HarmonyTests
//
//  Created by Joseph Mattiello on 10/21/17.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import Foundation
import CoreData

import Harmony

@objc(Course)
public class Course: NSManagedObject
{
}

extension Course: Syncable
{
    public class var syncablePrimaryKey: AnyKeyPath {
        return \Course.identifier
    }
    
    public var syncableKeys: Set<AnyKeyPath> {
        return [\Course.name]
    }
}
