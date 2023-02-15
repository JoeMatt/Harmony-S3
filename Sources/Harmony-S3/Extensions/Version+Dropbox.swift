//
//  Version+Dropbox.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import Foundation
import CoreData

import Harmony

import SwiftyDropbox

extension Version
{
    init?(metadata: Files.FileMetadata)
    {        
        self.init(identifier: metadata.rev, date: metadata.serverModified)
    }
}
