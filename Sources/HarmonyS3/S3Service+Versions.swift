//
//  S3Service+Versions.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import CoreData
import Foundation

import Harmony

import SotoS3

public extension S3Service {
    func fetchVersions(for record: AnyRecord, completionHandler: @escaping (Result<[Version], RecordError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        return progress
    }
}
