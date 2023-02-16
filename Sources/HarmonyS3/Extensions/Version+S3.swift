//
//  Version+S3.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import CoreData
import Foundation

import Harmony
import SotoS3

extension Version {
	init?(metadata: S3.ObjectVersion) {
		guard let identifier = metadata.versionId, let date = metadata.lastModified else { return nil }
        self.init(identifier: identifier, date: date)
    }
}
