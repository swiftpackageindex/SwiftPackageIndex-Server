import Vapor
import Fluent
import FluentPostgreSQL

final class ReconcilePackageListCommand: Command
{
  static let name = "reconcile_package_list"

  var arguments: [CommandArgument] = []
  var options: [CommandOption] = []
  var help = ["Synchronise the database with the master package list from GitHub."]

  func run(using context: CommandContext) throws -> Future<Void> {
    // Grab the GitHub master package list and the database's current package list
    let masterPackageList = try fetchMasterPackageList(context)
    let currentPackageList = try fetchCurrentPackageList(context)

    // Reconcile the package lists and add/remove any new/deleted packages
    return masterPackageList.and(currentPackageList).flatMap { (master, current) in
      let reconciler = PackageListReconciler(masterPackageList: master, currentPackageList: current)

      return context.container.withPooledConnection(to: .psql) { database in
        let packagesToAddFutures = reconciler.packagesToAdd.map { url -> Future<Package> in
          let package = Package(url: url)
          return package.create(on: database)
        }

        let packagesToDeleteFutures = reconciler.packagesToDelete.map { url in
          return Package.query(on: database).filter(\.url == url)
        }

        print(packagesToAddFutures)


//        .flatten(on: database)
//        .transform(to: ())

        return packagesToAddFutures.flatten(on: database).transform(to: ())
      }
    }
  }


//    return masterPackageList.and(currentPackageList).map { (master, current) in
//      // Reconcile the package lists
//      print("master = \(master)")
//      print("current = \(current)")
//
//
//      return context.container.withPooledConnection(to: .psql) { database in
//        // Add the new packages first
//        let additions = reconciler.packagesToAdd.map { url in
//          print("Inserting \(url)")
//          let package = Package(url: url)
//          return package.create(on: database)
//        }
//        .flatten(on: context)
//        .transform(to: ())
//
//        print(additions)
//        return additions
//      }
//
//
//
//
//      print(reconciler.packagesToAdd.count)
//      print(reconciler.packagesToDelete.count)
//    }
//  }

  func fetchMasterPackageList(_ context: CommandContext) throws -> Future<[URL]>
  {
    return try context.container.client()
      .get(masterPackageListURL)
      .flatMap(to: [String].self) { response in
        // GitHub serves the file as text/plain so it needs to be forced as JSON
        response.http.contentType = .json
        return try response.content.decode([String].self)
    }.map { urlStrings in
      urlStrings.compactMap { urlString in
        // Throw away bad URLs for now - This feels all sorts of wrong as we'll never know if URLs are being ignored. However it'll do for now as I don't know how to split this async chain into two.
        URL(string: urlString)
      }
    }
  }

  func fetchCurrentPackageList(_ context: CommandContext) throws -> Future<[URL]>
  {
    return context.container.withPooledConnection(to: .psql) { database in
      return Package.query(on: database).all()
    }.map { packages in
      // Grab all the package URLs
      packages.compactMap { $0.url }
    }
  }

  var masterPackageListURL: URL {
    guard let url = URL(string: "https://raw.githubusercontent.com/daveverwer/SwiftPMLibrary/master/packages.json")
      else { preconditionFailure("Failed to create the master package list URL") }
    return url
  }
}
