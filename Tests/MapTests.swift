/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import CollectionConcurrencyKit

final class MapTests: TestCase {
    func testNonThrowingAsyncMap() async {
        await runAsyncTest { array, collector in
            let values = await array.asyncMap { await collector.collectAndTransform($0) }
            XCTAssertEqual(values, array.map(String.init))
        }
    }

    func testThrowingAsyncMapThatDoesNotThrow() async {
        await runAsyncTest { array, collector in
            let values = try await array.asyncMap {
                try await collector.tryCollectAndTransform($0)
            }

            XCTAssertEqual(values, array.map(String.init))
        }
    }

    func testThrowingAsyncMapThatThrows() async {
        await runAsyncTest { array, collector in
            await self.verifyErrorThrown { error in
                try await array.asyncMap { int in
                    try await collector.tryCollectAndTransform(
                        int,
                        throwError: int == 3 ? error : nil
                    )
                }
            }

            XCTAssertEqual(collector.values, [0, 1, 2])
        }
    }

    func testNonThrowingConcurrentMap() async {
        await runAsyncTest { array, collector in
            let values = await array.concurrentMap {
                await collector.collectAndTransform($0)
            }

            XCTAssertEqual(values, array.map(String.init))
        }
    }

    func testThrowingConcurrentMapThatDoesNotThrow() async {
        await runAsyncTest { array, collector in
            let values = try await array.concurrentMap {
                try await collector.tryCollectAndTransform($0)
            }

            XCTAssertEqual(values, array.map(String.init))
        }
    }

    func testThrowingConcurrentMapThatThrows() async {
        await runAsyncTest { array, collector in
            await self.verifyErrorThrown { error in
                try await array.concurrentMap { int in
                    try await collector.tryCollectAndTransform(
                        int,
                        throwError: int == 3 ? error : nil
                    )
                }
            }
        }
    }
}
