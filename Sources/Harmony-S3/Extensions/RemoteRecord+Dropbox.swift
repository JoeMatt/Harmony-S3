//
//  RemoteRecord+Dropbox.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import Foundation
import CoreData

import Harmony

import SwiftyDropbox

extension RemoteRecord
{
    convenience init?(file: Files.FileMetadata, metadata: [HarmonyMetadataKey: Any]?, status: RecordStatus, context: NSManagedObjectContext)
    {
        guard let identifier = file.pathLower, let metadata = file.propertyGroups?.first?.metadata ?? metadata?.compactMapValues({ $0 as? String }) else { return nil }
        
        try? self.init(identifier: identifier, versionIdentifier: file.rev, versionDate: file.serverModified, metadata: metadata, status: status, context: context)
    }
}
