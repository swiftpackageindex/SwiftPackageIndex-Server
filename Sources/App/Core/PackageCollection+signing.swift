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

import Basics
import Fluent
@preconcurrency import PackageCollectionsModel
@preconcurrency import PackageCollectionsSigning
import Vapor


typealias SignedCollection = PackageCollectionSigning.Model.SignedCollection


extension SignedCollection {

    static func generate(db: Database,
                         filterBy filter: PackageCollection.Filter,
                         authorName: String? = nil,
                         collectionName: String? = nil,
                         keywords: [String]? = nil,
                         overview: String? = nil,
                         revision: Int? = nil) async throws -> SignedCollection {
        let collection  = try await PackageCollection.generate(db: db,
                                                               filterBy: filter,
                                                               authorName: authorName,
                                                               collectionName: collectionName,
                                                               keywords: keywords,
                                                               overview: overview,
                                                               revision: revision)
        return try await sign(collection: collection)
    }

    static func sign(collection: PackageCollection) async throws -> SignedCollection {
        guard let privateKey = Current.collectionSigningPrivateKey() else {
            throw AppError.envVariableNotSet("COLLECTION_SIGNING_PRIVATE_KEY")
        }

        return try await signer.sign(collection: collection,
                                     certChainPaths: Current.collectionSigningCertificateChain(),
                                     privateKeyPEM: privateKey)
    }

    static func validate(signedCollection: SignedCollection) async throws -> Bool {
        try await signer.validate(signedCollection: signedCollection)
        return true
    }

    static let certsDir = URL(fileURLWithPath: Current.fileManager.workingDirectory())
        .appendingPathComponent("Resources")
        .appendingPathComponent("Certs")

    static let signer = PackageCollectionSigning(
        trustedRootCertsDir: certsDir,
        additionalTrustedRootCerts: nil,
        observabilityScope: .ignored
    )

}


private extension ObservabilityScope {
    static var ignored: ObservabilityScope {
        ObservabilitySystem { _, _ in }.topScope
    }
}
