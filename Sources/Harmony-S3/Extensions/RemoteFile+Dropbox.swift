//
//  RemoteFile+Dropbox.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import Foundation
import CoreData

import Harmony

import SwiftyDropbox

extension RemoteFile
{
    convenience init?(file: Files.FileMetadata, metadata: [HarmonyMetadataKey: Any]?, context: NSManagedObjectContext)
    {
        guard let identifier = file.pathLower, let metadata = file.propertyGroups?.first?.metadata ?? metadata?.compactMapValues({ $0 as? String }) else { return nil }
        
        try? self.init(remoteIdentifier: identifier, versionIdentifier: file.rev, size: Int(file.size), metadata: metadata, context: context)
    }
}
