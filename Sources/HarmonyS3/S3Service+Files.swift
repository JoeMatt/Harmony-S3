//
//  S3Service+Files.swift
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
    func upload(_ file: File, for record: AnyRecord, metadata: [HarmonyMetadataKey: Any], context: NSManagedObjectContext, completionHandler: @escaping (Result<RemoteFile, FileError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        var didAddChildProgress = false

        return progress
    }

    func download(_ remoteFile: RemoteFile, completionHandler: @escaping (Result<File, FileError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        let fileIdentifier = remoteFile.identifier

        var didAddChildProgress = false

        return progress
    }

    func delete(_ remoteFile: RemoteFile, completionHandler: @escaping (Result<Void, FileError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        let fileIdentifier = remoteFile.identifier

        return progress
    }
}
