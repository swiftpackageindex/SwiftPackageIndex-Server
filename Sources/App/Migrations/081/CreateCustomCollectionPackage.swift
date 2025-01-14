// Copyright Dave Verwer, Sven A. Schmidt, and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Fluent
import SQLKit


struct CreateCustomCollectionPackage: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("custom_collections+packages")

        // managed fields
            .id()
            .field("created_at", .datetime)
            .field("updated_at", .datetime)

        // reference fields
            .field("custom_collection_id", .uuid,
                   .references("custom_collections", "id", onDelete: .cascade), .required)
            .field("package_id", .uuid,
                   .references("packages", "id", onDelete: .cascade), .required)

        // constraints
            .unique(on: "custom_collection_id", "package_id")

            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("custom_collections+packages").delete()
    }
}
