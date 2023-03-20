//
//  S3Service+Records.swift
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
    func fetchAllRemoteRecords(context: NSManagedObjectContext, completionHandler: @escaping (Result<(Set<RemoteRecord>, Data), FetchError>) -> Void) -> Progress {
        fetchRemoteRecords(changeToken: nil, updatedStatus: .normal, context: context, completionHandler: { result in
            let result = result.map { updatedRecords, _, changeToken in
                (updatedRecords, changeToken)
            }

            completionHandler(result)
        })
    }

    func fetchChangedRemoteRecords(changeToken: Data, context: NSManagedObjectContext, completionHandler: @escaping (Result<(Set<RemoteRecord>, Set<String>, Data), FetchError>) -> Void) -> Progress {
        fetchRemoteRecords(changeToken: changeToken, updatedStatus: .updated, context: context, completionHandler: completionHandler)
    }

    private func fetchRemoteRecords(changeToken: Data?, updatedStatus: RecordStatus, context: NSManagedObjectContext, completionHandler: @escaping (Result<(Set<RemoteRecord>, Set<String>, Data), FetchError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        return progress
    }

    func upload(_ record: AnyRecord, metadata: [HarmonyMetadataKey: Any], context: NSManagedObjectContext, completionHandler: @escaping (Result<RemoteRecord, RecordError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        return progress
    }

    func download(_ record: AnyRecord, version: Version, context: NSManagedObjectContext, completionHandler: @escaping (Result<LocalRecord, RecordError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        return progress
    }

    func delete(_ record: AnyRecord, completionHandler: @escaping (Result<Void, RecordError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        return progress
    }

    func updateMetadata(_ metadata: [HarmonyMetadataKey: Any], for record: AnyRecord, completionHandler: @escaping (Result<Void, RecordError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        return progress
    }
}
