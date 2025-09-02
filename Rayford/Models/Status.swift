//
//  Status.swift
//  Rayford
//
//  Created by Weiyi Kong on 28/8/2025.
//

import Foundation

enum Status<Progress, Success, Failure> where Failure : Error {
    case idle
    case progress(Progress)
    case success(Success)
    case failure(Failure)
}

extension Status {
    init(result: Result<Success, Failure>) {
        switch result {
        case let .success(success): self = .success(success)
        case let .failure(failure): self = .failure(failure)
        }
    }
}

extension Status {
    func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> Status<Progress, Success, NewFailure> where NewFailure : Error {
        switch self {
        case .idle: .idle
        case let .progress(progress): .progress(progress)
        case let .success(success): .success(success)
        case let .failure(failure): .failure(transform(failure))
        }
    }

    func flatMapError<NewFailure>(_ transform: (Failure) -> Status<Progress, Success, NewFailure>) -> Status<Progress, Success, NewFailure> where NewFailure : Error {
        switch self {
        case .idle: .idle
        case let .progress(progress): .progress(progress)
        case let .success(value): .success(value)
        case let .failure(error): transform(error)
        }
    }
}

extension Result {
    func status<Progress>() -> Status<Progress, Success, Failure> {
        Status<Progress, Success, Failure>(result: self)
    }
}

extension Result where Failure == Error {
    func map<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Failure> where NewSuccess : ~Copyable {
        switch self {
        case let .success(success): do { return .success(try transform(success)) } catch { return .failure(error) }
        case let .failure(failure): return .failure(failure)
        }
    }
}
