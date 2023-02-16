//
//  RemoteRecord+S3.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import CoreData
import Foundation
import Harmony

extension RemoteRecord {

	convenience init?(file: S3.ObjectVersion, metadata: [HarmonyMetadataKey: Any]?, status: RecordStatus, context: NSManagedObjectContext) {
		guard let identifier = file.key, let versionIdentifier = file.versionId, let date = file.lastModified else { return nil }

		let metadata: [HarmonyMetadataKey: String] = [:]

		try? self.init(identifier: identifier, versionIdentifier: versionIdentifier, versionDate: date, metadata: metadata, status: status, context: context)
	}
}
