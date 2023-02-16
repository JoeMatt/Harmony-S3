//
//  RemoteFile+S3.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import CoreData
import Foundation
import Harmony
import SotoS3

extension RemoteFile {
	convenience init?(file: S3.ObjectVersion, metadata: [HarmonyMetadataKey: Any]?, context: NSManagedObjectContext) {
		guard let identifier = file.key, let versionIdentifier = file.versionId, let size = file.size else { return nil }

		let metadata: [HarmonyMetadataKey: String] = [:]

        try? self.init(remoteIdentifier: identifier, versionIdentifier: versionIdentifier, size: Int(size), metadata: metadata, context: context)
    }
}
