import Vapor


extension Search {
    enum Result: Equatable {
        case author(AuthorResult)
        case keyword(KeywordResult)
        case package(PackageResult)

        init?(_ record: DBRecord) {
            // don't show non-package results on production yet
            let environment = (try? Environment.detect()) ?? .development
            if environment == .production && !record.isPackage {
                return nil
            }
            // -- end --
            switch (record.matchType, record.keyword) {
                case let (.author, .some(repoOwner)):
                    self = .author(.init(name: repoOwner))
                case (.author, .none):
                    return nil
                case let (.keyword, .some(kw)):
                    self = .keyword(.init(keyword: kw))
                case (.keyword, .none):
                    return nil
                case (.package, _):
                    self = .package(
                        .init(packageId: record.packageId,
                              packageName: record.packageName,
                              packageURL: record.packageURL,
                              repositoryName: record.repositoryName,
                              repositoryOwner: record.repositoryOwner,
                              summary: record.summary?.replaceShorthandEmojis())
                    )
            }
        }

        var isKeyword: Bool {
            switch self {
                case .author, .package:
                    return false
                case .keyword:
                    return true
            }
        }

        var isPackage: Bool {
            switch self {
                case .author, .keyword:
                    return false
                case .package:
                    return true
            }
        }
    }

    struct AuthorResult: Codable, Equatable {
        var name: String
    }

    struct KeywordResult: Codable, Equatable {
        var keyword: String
    }

    struct PackageResult: Codable, Equatable {
        var packageId: Package.Id?
        var packageName: String?
        var packageURL: String?
        var repositoryName: String?
        var repositoryOwner: String?
        var summary: String?
    }
}


// https://github.com/apple/swift-evolution/blob/main/proposals/0295-codable-synthesis-for-enums-with-associated-values.md
@available(swift, deprecated: 5.5, message: "Remove after switching to Swift 5.5 (Codable auto-synthesis for enums with assoc values SE-0295)")
extension Search.Result: Codable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard container.allKeys.count == 1 else {
            throw DecodingError.typeMismatch(Self.self, .init(
                codingPath: container.codingPath,
                debugDescription: "Invalid number of keys found, expected one."
            ))
        }

        switch container.allKeys.first! {
            case .author:
                let nestedContainer = try container
                    .nestedContainer(keyedBy: AutogeneratedCodingkeys.self,
                                     forKey: .author)
                let value = try nestedContainer
                    .decode(Search.AuthorResult.self, forKey: ._0)
                self = .author(value)
            case .keyword:
                let nestedContainer = try container
                    .nestedContainer(keyedBy: AutogeneratedCodingkeys.self,
                                     forKey: .keyword)
                let value = try nestedContainer
                    .decode(Search.KeywordResult.self, forKey: ._0)
                self = .keyword(value)
            case .package:
                let nestedContainer = try container
                    .nestedContainer(keyedBy: AutogeneratedCodingkeys.self,
                                     forKey: .package)
                let value = try nestedContainer
                    .decode(Search.PackageResult.self, forKey: ._0)
                self = .package(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case let .author(value):
                var nestedContainer = container
                    .nestedContainer(keyedBy: AutogeneratedCodingkeys.self,
                                     forKey: .author)
                try nestedContainer.encode(value, forKey: ._0)
            case let .keyword(value):
                var nestedContainer = container
                    .nestedContainer(keyedBy: AutogeneratedCodingkeys.self,
                                     forKey: .keyword)
                try nestedContainer.encode(value, forKey: ._0)
            case let .package(value):
                var nestedContainer = container
                    .nestedContainer(keyedBy: AutogeneratedCodingkeys.self,
                                     forKey: .package)
                try nestedContainer.encode(value, forKey: ._0)
        }
    }

    enum CodingKeys: CodingKey {
        case author
        case keyword
        case package
    }

    enum AutogeneratedCodingkeys: CodingKey {
        case _0
    }
}
