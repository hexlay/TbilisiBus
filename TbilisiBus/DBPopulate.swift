import Foundation
import SQLite

let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
let truePath = "\(path)/db.sqlite3"

class DBPopulate {
    
    var db: Connection?
    let tableName = "t_favorites"
    let tablePrep = Table("t_favorites")
    let pid = Expression<Int64>("p_id")
    let id = Expression<Int>("s_id")
    let name = Expression<String>("name")
    
    init() {
        do {
            self.db = try Connection(truePath)
            try db?.run(tablePrep.create(ifNotExists: true) { t in
                t.column(pid, primaryKey: true)
                t.column(id)
                t.column(name)
            })
        } catch let error {
            print("Error info: \(error)")
        }
    }
    
    func addFavorite(gid: Int, gname: String) {
        do {
            if isExist(gid: gid) == 0 {
                try db?.run(tablePrep.insert(name <- gname, id <- gid))
            }
        } catch let error {
            print("Error info: \(error)")
        }
    }
    
    func isExist(gid: Int) -> Int {
        do {
            let count = try db?.scalar(tablePrep.filter(id == gid).count)
            return count!
        } catch let error {
            print("Error info: \(error)")
        }
        return 0
    }
    
    func deleteFavorite(gid: Int) {
        do {
            try db?.run(tablePrep.filter(id == gid).delete())
        } catch let error {
            print("Error info: \(error)")
        }
    }
    
}

