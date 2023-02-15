//
//  Result+Dropbox.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import Harmony
import SwiftyDropbox

extension Result
{
    init<E>(_ value: Success?, _ error: SwiftyDropbox.CallError<E>?) where Failure == DropboxService.CallError<E>
    {
        switch (value, error)
        {
        case (let value?, _): self = .success(value)
        case (_, let error?): self = .failure(DropboxService.CallError(error))
        case (nil, nil): self = .failure(DropboxService.CallError(SwiftyDropbox.CallError<E>.clientError(ServiceError.invalidResponse)))
        }
    }
}

extension Result where Success == Void
{
    init<E>(_ error: SwiftyDropbox.CallError<E>?) where Failure == DropboxService.CallError<E>
    {
        if let error = error
        {
            self = .failure(DropboxService.CallError(error))
        }
        else
        {
            self = .success
        }
    }
}
