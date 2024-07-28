//
//  filter.swift
//  
//
//  Created by Jeremy Bannister on 2/24/22.
//

// MARK: - Filter

@available(iOS 13.0, macOS 10.15.0, watchOS 6, tvOS 13, *)
extension Sequence {
    
    ///
    public func asyncFilter(
        _ operation: (Element)async throws->Bool
    ) async rethrows -> Array<Element> {
        
        ///
        try await self.asyncCompactMap {
            
            ///
            try await operation($0) ? $0 : nil
        }
    }

    ///
    public func concurrentFilter(
        withPriority priority: TaskPriority? = nil,
        _ operation: @escaping (Element)async->Bool
    ) async -> Array<Element> {
        
        ///
        await self.concurrentCompactMap(withPriority: priority) {
            
            ///
            await operation($0) ? $0 : nil
        }
    }

    ///
    public func concurrentFilter(
        withPriority priority: TaskPriority? = nil,
        _ operation: @escaping (Element)async throws->Bool
    ) async throws -> Array<Element> {
        
        ///
        try await self.concurrentCompactMap(withPriority: priority) {
            
            ///
            try await operation($0) ? $0 : nil
        }
    }
}
