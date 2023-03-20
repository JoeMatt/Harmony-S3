//
//  Result+S3.swift
//  Harmony-S3
//
//  Created by Joseph Mattiello on 2/15/23.
//  Copyright © 2023 Joseph Mattiello. All rights reserved.
//

import Harmony
import SotoS3

extension Result where Failure == Error {
	init(_ value: Success?, _ error: Error?) {
		switch (value, error) {
		case let (value?, _): self = .success(value)
		case let (_, error?): self = .failure(error)
		case (nil, nil): self = .failure(ServiceError.invalidResponse)
		}
	}
}

extension Result where Success == Void, Failure == Error {
	init(_ error: Error?) {
		if let error = error {
			self = .failure(error)
		} else {
			self = .success
		}
	}
}
