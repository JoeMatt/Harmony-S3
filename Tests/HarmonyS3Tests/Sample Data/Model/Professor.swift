//
//  Professor.swift
//  HarmonyTests
//
//  Created by Joseph Mattiello on 10/21/17.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import Foundation
import CoreData

import Harmony

@objc(Professor)
public class Professor: NSManagedObject
{    
}

extension Professor: Syncable
{
    public class var syncablePrimaryKey: AnyKeyPath {
        return \Professor.identifier
    }
    
    public var syncableKeys: Set<AnyKeyPath> {
        return [\Professor.name]
    }
}
