//
//  Optional+map_asyncOverload.swift
//  
//
//  Created by Jeremy Bannister on 2/16/22.
//

///
@available(iOS 13.0, macOS 10.15.0, watchOS 6, tvOS 13, *)
public extension Optional {
    
    ///
    func map
        <NewValue>
        (_ transform: (Wrapped)async throws->NewValue)
    async rethrows -> Optional<NewValue> {
        
        ///
        switch self {
            
        ///
        case .some (let value):
            return try await .some(transform(value))
            
        ///
        case .none:
            return .none
        }
    }
}
