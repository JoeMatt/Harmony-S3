//
//  PropertyGroup+Harmony.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import SwiftyDropbox

import Harmony

extension FileProperties.PropertyGroup
{
    var metadata: [HarmonyMetadataKey: String] {
        let metadata = self.fields.reduce(into: [:]) { $0[HarmonyMetadataKey($1.name)] = $1.value }
        return metadata
    }
    
    convenience init<T>(templateID: String, metadata: [HarmonyMetadataKey: T])
    {
        let propertyFields = metadata.compactMap { (key, value) -> FileProperties.PropertyField? in
            guard let value = value as? String else { return nil }
            
            let propertyField = FileProperties.PropertyField(name: key, value: value)
            return propertyField
        }
        
        self.init(templateId: templateID, fields: propertyFields)
    }
}
