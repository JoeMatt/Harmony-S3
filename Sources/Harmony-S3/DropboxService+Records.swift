//
//  DropboxService+Records.swift
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

        do {
            guard let dropboxClient = dropboxClient else { throw AuthenticationError.notAuthenticated }
            let path = try remotePath(filename: nil)

            var templateIDs = [String]()
            if let (templateID, _) = propertyGroupTemplate {
                templateIDs.append(templateID)
            }

            func fetchAllRecords(cursor: String?, completionHandler: @escaping (Result<(Set<RemoteRecord>, Set<String>, Data), FetchError>) -> Void) {
                var updatedRecords = Set<RemoteRecord>()
                var deletedRecordIDs = Set<String>()

                func _fetchRecords(cursor: String?) {
                    if let cursor = cursor {
                        let request = dropboxClient.files.listFolderContinue(cursor: cursor).response(queue: responseQueue, completionHandler: finish)

                        progress.cancellationHandler = {
                            request.cancel()
                            completionHandler(.failure(FetchError(GeneralError.cancelled)))
                        }
                    } else {
                        let request = dropboxClient.files.listFolder(path: path, includeDeleted: true, includePropertyGroups: .filterSome(templateIDs))
                            .response(queue: responseQueue, completionHandler: finish)

                        progress.cancellationHandler = {
                            request.cancel()
                            completionHandler(.failure(FetchError(GeneralError.cancelled)))
                        }
                    }
                }

                func finish<T>(_ result: Files.ListFolderResult?, _ error: SwiftyDropbox.CallError<T>?) {
                    context.perform {
                        do {
                            let result = try self.process(Result(result, error))

                            let remoteRecords = result.entries.lazy.compactMap { $0 as? Files.FileMetadata }.compactMap { RemoteRecord(file: $0, metadata: nil, status: updatedStatus, context: context) }
                            updatedRecords.formUnion(remoteRecords)

                            let deletedIDs = result.entries.lazy.compactMap { ($0 as? Files.DeletedMetadata)?.pathLower }
                            deletedRecordIDs.formUnion(deletedIDs)

                            if result.hasMore {
                                _fetchRecords(cursor: result.cursor)
                            } else {
                                guard let changeToken = result.cursor.data(using: .utf8) else {
                                    throw ServiceError.invalidResponse
                                }

                                completionHandler(.success((updatedRecords, deletedRecordIDs, changeToken)))
                            }
                        } catch {
                            completionHandler(.failure(FetchError(error)))
                        }
                    }
                }

                _fetchRecords(cursor: cursor)
            }

            func finish(_ result: Result<(Set<RemoteRecord>, Set<String>, Data), FetchError>) {
                completionHandler(result)
            }

            if let changeToken = changeToken {
                guard let cursor = String(data: changeToken, encoding: .utf8) else { throw FetchError.invalidChangeToken(changeToken) }
                fetchAllRecords(cursor: cursor, completionHandler: finish)
            } else {
                fetchAllRecords(cursor: nil, completionHandler: finish)
            }
        } catch {
            completionHandler(.failure(FetchError(error)))
        }

        return progress
    }

    func upload(_ record: AnyRecord, metadata: [HarmonyMetadataKey: Any], context: NSManagedObjectContext, completionHandler: @escaping (Result<RemoteRecord, RecordError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        validateMetadata(metadata) { result in
            do {
                let templateID = try result.get()

                guard let dropboxClient = self.dropboxClient else { throw AuthenticationError.notAuthenticated }

                try record.perform { managedRecord in
                    guard let localRecord = managedRecord.localRecord else { throw ValidationError.nilLocalRecord }

                    let data = try JSONEncoder().encode(localRecord)

                    let path: String
                    let mode: Files.WriteMode

                    if let remoteRecord = managedRecord.remoteRecord {
                        path = remoteRecord.identifier
                        mode = .update(remoteRecord.version.identifier)
                    } else {
                        path = try self.remotePath(filename: managedRecord.recordID.description)
                        mode = .add
                    }

                    let propertyGroup = FileProperties.PropertyGroup(templateID: templateID, metadata: metadata)

                    let request = dropboxClient.files.upload(path: path, mode: mode, autorename: false, mute: true, propertyGroups: [propertyGroup], strictConflict: false, input: data)
                        .response(queue: self.responseQueue) { file, error in
                            context.perform {
                                do {
                                    let file = try self.process(Result(file, error))

                                    guard let remoteRecord = RemoteRecord(file: file, metadata: metadata, status: .normal, context: context) else {
                                        throw ServiceError.invalidResponse
                                    }

                                    completionHandler(.success(remoteRecord))
                                } catch {
                                    completionHandler(.failure(RecordError(record, error)))
                                }
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
        }

        return progress
    }

    func download(_ record: AnyRecord, version: Version, context: NSManagedObjectContext, completionHandler: @escaping (Result<LocalRecord, RecordError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        do {
            guard let dropboxClient = dropboxClient else { throw AuthenticationError.notAuthenticated }

            try record.perform { managedRecord in
                guard let remoteRecord = managedRecord.remoteRecord else { throw ValidationError.nilRemoteRecord }

                let request = dropboxClient.files.download(path: remoteRecord.identifier, rev: version.identifier).response(queue: self.responseQueue) { result, error in
                    context.perform {
                        do {
                            let (_, data) = try self.process(Result(result, error))

                            let decoder = JSONDecoder()
                            decoder.managedObjectContext = context

                            let record = try decoder.decode(LocalRecord.self, from: data)

                            completionHandler(.success(record))
                        } catch {
                            completionHandler(.failure(RecordError(record, error)))
                        }
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

    func delete(_ record: AnyRecord, completionHandler: @escaping (Result<Void, RecordError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        do {
            guard let dropboxClient = dropboxClient else { throw AuthenticationError.notAuthenticated }

            try record.perform { managedRecord in
                guard let remoteRecord = managedRecord.remoteRecord else { throw ValidationError.nilRemoteRecord }

                let request = dropboxClient.files.deleteV2(path: remoteRecord.identifier).response(queue: self.responseQueue) { _, error in
                    do {
                        try self.process(Result(error))

                        completionHandler(.success)
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

    func updateMetadata(_ metadata: [HarmonyMetadataKey: Any], for record: AnyRecord, completionHandler: @escaping (Result<Void, RecordError>) -> Void) -> Progress {
        let progress = Progress.discreteProgress(totalUnitCount: 1)

        validateMetadata(metadata) { result in
            do {
                let templateID = try result.get()

                guard let dropboxClient = self.dropboxClient else { throw AuthenticationError.notAuthenticated }

                try record.perform { managedRecord in
                    guard let remoteRecord = managedRecord.remoteRecord else { throw ValidationError.nilRemoteRecord }

                    let updatedFields = metadata.filter { $0.value is String }.map { FileProperties.PropertyField(name: $0, value: $1 as! String) }
                    let removedFields = metadata.filter { $0.value is NSNull }.map { $0.key }

                    let propertyGroupUpdate = FileProperties.PropertyGroupUpdate(templateId: templateID, addOrUpdateFields: updatedFields, removeFields: removedFields)
                    let request = dropboxClient.file_properties.propertiesUpdate(path: remoteRecord.identifier, updatePropertyGroups: [propertyGroupUpdate]).response(queue: self.responseQueue) { _, error in
                        do {
                            try self.process(Result(error))

                            completionHandler(.success)
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
        }

        return progress
    }
}
