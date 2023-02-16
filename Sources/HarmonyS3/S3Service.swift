//
//  S3Service.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import CoreData
import Foundation
import Harmony

#if canImport(UIKit)
import UIKit
#endif

@_exported import SotoS3
//public typealias Account = S3.Account

extension S3Service {
    enum S3Error: LocalizedError {
        case nilDirectoryName

        var errorDescription: String? {
            switch self {
            case .nilDirectoryName: return NSLocalizedString("There is no provided S3 directory name.", comment: "")
            }
        }
    }
}

public class S3Service: NSObject, Harmony.Service {
    public typealias CompletionHandler = Result<Harmony.Account, Harmony.AuthenticationError>

    public static let shared = S3Service()

    public let localizedName = NSLocalizedString("S3", comment: "")
    public let identifier = "com.rileytestut.Harmony.S3"

    public var clientID: String? {
        didSet {
            guard let clientID = clientID else { return }
			// TODO: mySecretAccessKey
//			let mySecretAccessKey = ""
//			let awsClient = AWSClient(
//				credentialProvider: .static(accessKeyId: clientID, secretAccessKey: mySecretAccessKey),
//				httpClientProvider: .createNew
//			)
        }
    }

    public var preferredDirectoryName: String?

	internal private(set) var client: AWSClient?
    internal let responseQueue = DispatchQueue(label: "com.rileytestut.Harmony.S3.responseQueue")

    private var authorizationCompletionHandlers = [(CompletionHandler) -> Void]()

    private var accountID: String? {
        get {
            UserDefaults.standard.string(forKey: "HarmonyS3_accountID")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "HarmonyS3_accountID")
        }
    }

    override private init() {
        super.init()
    }
}

public extension S3Service {
    func authenticate(withPresentingViewController viewController: UIViewController, completionHandler: @escaping (CompletionHandler) -> Void) {
        authorizationCompletionHandlers.append(completionHandler)

//        S3ClientsManager.authorizeFromController(UIApplication.shared, controller: viewController) { url in
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
    }

    func authenticateInBackground(completionHandler: @escaping (CompletionHandler) -> Void) {
        guard let accountID = accountID else { return completionHandler(.failure(.noSavedCredentials)) }

        authorizationCompletionHandlers.append(completionHandler)

//        S3ClientsManager.reauthorizeClient(accountID)

        finishAuthentication()
    }

    func deauthenticate(completionHandler: @escaping (Result<Void, DeauthenticationError>) -> Void) {
//        S3ClientsManager.unlinkClients()

        accountID = nil
        completionHandler(.success)
    }
}

private extension S3Service {
    func finishAuthentication() {
        func finish(_ result: CompletionHandler) {
            // Reset self.authorizationCompletionHandlers _before_ calling all the completion handlers.
            // This stops us from accidentally calling completion handlers twice in some instances.
            let completionHandlers = authorizationCompletionHandlers
            authorizationCompletionHandlers.removeAll()

            completionHandlers.forEach { $0(result) }
        }
    }

    func createSyncDirectoryIfNeeded(completionHandler: @escaping (Result<Void, Error>) -> Void) {

    }
}

extension S3Service {
   
}
