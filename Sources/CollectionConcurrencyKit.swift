/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

// MARK: - ForEach

///
@available(iOS 13.0, macOS 10.15.0, watchOS 6, tvOS 13, *)
extension Sequence where Element: Sendable {
    /// Run an async closure for each element within the sequence.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter operation: The closure to run for each element.
    /// - throws: Rethrows any error thrown by the passed closure.
    public func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        
        ///
        for element in self {
            
            ///
            try await operation(element)
        }
    }

    /// Run an async closure for each element within the sequence.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter operation: The closure to run for each element.
    public func concurrentForEach(
        withPriority priority: TaskPriority? = nil,
        _ operation: @escaping @Sendable (Element) async -> Void
    ) async {
        
        ///
        await withTaskGroup(of: Void.self) { group in
            
            ///
            for element in self {
                
                ///
                group.addTask(priority: priority) {
                    await operation(element)
                }
            }
        }
    }

    /// Run an async closure for each element within the sequence.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter operation: The closure to run for each element.
    /// - throws: Rethrows any error thrown by the passed closure.
    public func concurrentForEach(
        withPriority priority: TaskPriority? = nil,
        _ operation: @escaping @Sendable (Element) async throws -> Void
    ) async throws {
        
        ///
        try await withThrowingTaskGroup(of: Void.self) { group in
            
            ///
            for element in self {
                
                ///
                group.addTask(priority: priority) {
                    try await operation(element)
                }
            }

            /// Propagate any errors thrown by the group's tasks:
            for try await _ in group {}
        }
    }
}

// MARK: - Map

///
@available(iOS 13.0, macOS 10.15.0, watchOS 6, tvOS 13, *)
extension Sequence where Element: Sendable {
    
    /// Transform the sequence into an array of new values using
    /// an async closure.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence.
    /// - throws: Rethrows any error thrown by the passed closure.
    public func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        
        ///
        var values = [T]()
        
        ///
        for element in self {
            try await values
                .append(
                    transform(element)
                )
        }
        
        ///
        return values
    }

    /// Transform the sequence into an array of new values using
    /// an async closure.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence.
    public func concurrentMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @escaping @Sendable (Element) async -> T
    ) async -> [T] {
        
        ///
        let tasks =
            self.map { element in
                Task(priority: priority) {
                    await transform(element)
                }
            }
        
        ///
        return
            await tasks
                .asyncMap { task in
                    await task.value
                }
    }

    /// Transform the sequence into an array of new values using
    /// an async closure.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence.
    /// - throws: Rethrows any error thrown by the passed closure.
    public func concurrentMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @escaping @Sendable (Element) async throws -> T
    ) async throws -> [T] {
        
        ///
        let tasks =
            self.map { element in
                Task(priority: priority) {
                    try await transform(element)
                }
            }
        
        ///
        return
            try await tasks
                .asyncMap { task in
                    try await task.value
                }
    }
}

// MARK: - CompactMap

///
@available(iOS 13.0, macOS 10.15.0, watchOS 6, tvOS 13, *)
extension Sequence where Element: Sendable {
    
    /// Transform the sequence into an array of new values using
    /// an async closure that returns optional values. Only the
    /// non-`nil` return values will be included in the new array.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   except for the values that were transformed into `nil`.
    /// - throws: Rethrows any error thrown by the passed closure.
    public func asyncCompactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        
        ///
        var values = [T]()
        
        ///
        for element in self {
            
            ///
            guard let value = try await transform(element) else {
                continue
            }
            
            ///
            values.append(value)
        }
        
        ///
        return values
    }

    /// Transform the sequence into an array of new values using
    /// an async closure that returns optional values. Only the
    /// non-`nil` return values will be included in the new array.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   except for the values that were transformed into `nil`.
    public func concurrentCompactMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @escaping @Sendable (Element) async -> T?
    ) async -> [T] {
        
        ///
        let tasks =
            self.map { element in
                Task(priority: priority) {
                    await transform(element)
                }
            }
        
        ///
        return
            await tasks
                .asyncCompactMap { task in
                    await task.value
                }
    }

    /// Transform the sequence into an array of new values using
    /// an async closure that returns optional values. Only the
    /// non-`nil` return values will be included in the new array.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   except for the values that were transformed into `nil`.
    /// - throws: Rethrows any error thrown by the passed closure.
    public func concurrentCompactMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @escaping @Sendable (Element) async throws -> T?
    ) async throws -> [T] {
        
        ///
        let tasks =
            self.map { element in
                Task(priority: priority) {
                    try await transform(element)
                }
            }
        
        ///
        return
            try await tasks
                .asyncCompactMap { task in
                    try await task.value
                }
    }
}

// MARK: - FlatMap

///
@available(iOS 13.0, macOS 10.15.0, watchOS 6, tvOS 13, *)
extension Sequence where Element: Sendable {
    
    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    /// - throws: Rethrows any error thrown by the passed closure.
    public func asyncFlatMap<T: Sequence>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T.Element] {
        
        ///
        var values = [T.Element]()
        
        ///
        for element in self {
            
            ///
            try await values
                .append(
                    contentsOf: transform(element)
                )
        }
        
        ///
        return values
    }

    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    public func concurrentFlatMap<
        T: Sequence & Sendable
    >(
        withPriority priority: TaskPriority? = nil,
        _ transform: @escaping @Sendable (Element) async -> T
    ) async -> [T.Element] {
        
        ///
        let tasks =
            self.map { element in
                Task(priority: priority) {
                    await transform(element)
                }
            }
        
        ///
        return
            await tasks
                .asyncFlatMap { task in
                    await task.value
                }
    }

    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    /// - throws: Rethrows any error thrown by the passed closure.
    public func concurrentFlatMap<T: Sequence & Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @escaping @Sendable (Element) async throws -> T
    ) async throws -> [T.Element] {
        
        ///
        let tasks =
            self.map { element in
                Task(priority: priority) {
                    try await transform(element)
                }
            }
        
        ///
        return
            try await tasks
                .asyncFlatMap { task in
                    try await task.value
                }
    }
}


// MARK: - Reduce

///
@available(iOS 13.0, macOS 10.15.0, watchOS 6, tvOS 13, *)
extension Sequence {
    
    ///
    public func asyncReduce<
        Result
    >(
        into initialResult: Result,
        _ updateAccumulatingResult: (inout Result, Element)async throws->()
    ) async rethrows -> Result {
        
        ///
        var accumulation: Result = initialResult
        
        ///
        for element in self {
            try await updateAccumulatingResult(&accumulation, element)
        }

        return accumulation
    }
}
