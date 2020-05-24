import Foundation
import ShellOut


enum GitError: LocalizedError {
    case invalidInteger
    case invalidTimestamp
    case invalidRevisionInfo
}


enum Git {

    static func commitCount(at path: String) throws -> Int {
        let res = try Current.shell.run(
            command: .init(string: "git rev-list --count HEAD"),
            at: path)
        guard let count = Int(res) else {
            throw GitError.invalidInteger
        }
        return count
    }

    static func firstCommitDate(at path: String) throws -> Date {
        let res = try Current.shell.run(
            command: .init(string: #"git log --max-parents=0 -n1 --format=format:"%ct""#),
            at: path)
        guard let timestamp = TimeInterval(res) else {
            throw GitError.invalidTimestamp
        }
        return Date(timeIntervalSince1970: timestamp)
    }

    static func lastCommitDate(at path: String) throws -> Date {
        let res = try Current.shell.run(
            command: .init(string: #"git log -n1 --format=format:"%ct""#),
            at: path)
        guard let timestamp = TimeInterval(res) else {
            throw GitError.invalidTimestamp
        }
        return Date(timeIntervalSince1970: timestamp)
    }

    static func tag(at path: String) throws -> [Reference] {
        let tags = try Current.shell.run(command: .init(string: "git tag"), at: path)
        return tags.split(separator: "\n")
            .map(String.init)
            .compactMap { tag in SemVer(tag).map { ($0, tag) } }
            .map { Reference.tag($0, $1) }
    }

    static func showDate(_ commit: CommitHash, at path: String) throws -> Date {
        let res = try Current.shell.run(command: .init(string: "git show -s --format=%ct \(commit)"),
                                        at: path)
        guard let timestamp = TimeInterval(res) else {
            throw GitError.invalidTimestamp
        }
        return Date(timeIntervalSince1970: timestamp)
    }

    static func revisionInfo(_ reference: Reference, at path: String) throws -> RevisionInfo {
        let dash = "-"
        let res = try Current.shell.run(
            command: .init(string: #"git log -n1 --format=format:"%H\#(dash)%ct" \#(reference)"#),
            at: path
        )
        let parts = res.components(separatedBy: dash)
        guard parts.count == 2 else { throw GitError.invalidRevisionInfo }
        let hash = parts[0]
        guard let timestamp = TimeInterval(parts[1]) else { throw GitError.invalidTimestamp }
        let date = Date(timeIntervalSince1970: timestamp)
        return .init(commit: hash, date: date)
    }

    struct RevisionInfo: Equatable {
        let commit: CommitHash
        let date: Date
    }
}
