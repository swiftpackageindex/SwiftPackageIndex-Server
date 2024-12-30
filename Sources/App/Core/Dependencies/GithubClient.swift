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


import Dependencies
import DependenciesMacros


@DependencyClient
struct GithubClient {
    var fetchLicense: @Sendable (_ owner: String, _ repository: String) async -> Github.License?
}


extension GithubClient: DependencyKey {
    static var liveValue: Self {
        .init(
            fetchLicense: { owner, repo in await Github.fetchLicense(owner: owner, repository: repo) }
        )
    }
}


extension GithubClient: TestDependencyKey {
    static var testValue: Self { Self() }
}


extension DependencyValues {
    var github: GithubClient {
        get { self[GithubClient.self] }
        set { self[GithubClient.self] = newValue }
    }
}