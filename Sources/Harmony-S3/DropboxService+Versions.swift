//
//  DropboxService+Versions.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import CoreData
import Foundation

import Harmony

import SwiftyDropbox

public extension DropboxService {
    func fetchVersions(for record: AnyRecord, completionHandler: @escaping (Result<[Version], RecordError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        do {
            guard let dropboxClient = dropboxClient else { throw AuthenticationError.notAuthenticated }

            try record.perform { managedRecord in
                guard let remoteRecord = managedRecord.remoteRecord else { throw ValidationError.nilRemoteRecord }

                let request = dropboxClient.files.listRevisions(path: remoteRecord.identifier, limit: 100).response(queue: self.responseQueue) { result, error in
                    do {
                        let result = try self.process(Result(result, error))

                        let versions = result.entries.compactMap(Version.init(metadata:))
                        completionHandler(.success(versions))
                    } catch {
                        completionHandler(.failure(RecordError(record, error)))
                    }
                }

                progress.cancellationHandler = {
                    request.cancel()
                    completionHandler(.failure(RecordError(record, GeneralError.cancelled)))
                }
            }
        } catch {
            completionHandler(.failure(RecordError(record, error)))
        }

        return progress
    }
}
