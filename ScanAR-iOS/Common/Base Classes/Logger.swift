//
//  Logger.swift
//
//
//  Created by macbook on 30.09.2020.
//

import Foundation

enum LoggerTypes: Int {
    case all
    case requests
    case responses
    case lifecycle
    case gcd
    case parserFactory
    case parserEntity
    case localNotifications
}


class Logger {

    static let shared = Logger()
    
    var enabled: Bool = true
    
    init() {}

    func log(_ error: Error?, descriptions: String? = "", path: String = #file, line: Int = #line, function: String = #function) {
        print("\n")
        //print(" - LOGGER \(time()) ❌ ERROR 😱 file=\((path as NSString).lastPathComponent)")

        if let e = error {
            debugPrint(e)
            print(" ")
        }

        if !(descriptions ?? "").isEmpty {
            print(descriptions!)
            print(" ")
        }
    }

    func log(_ string: String? = "", type: LoggerTypes = .all, function: String = #function) {
        if let s = string, !s.isEmpty {
            prepare("\(s)", type: type)
            
        } else {
            prepare("\(function)", type: type)
        }
    }

    func log(_ data: Data?) {
        guard let data = data else {
            return
        }

        prepare(String(data: data, encoding: String.Encoding.utf8) ?? "", type: .all)
    }

    func log(_ url: URL?) {
        guard let url = url else {
            return
        }

        prepare(url.absoluteString, type: .all)
    }

    // MARK: - Fileprivate
    // just comment unnecessary printing logs
    fileprivate func prepare(_ string: String, type: LoggerTypes) {
        switch type {
        case .all:
            //printStr(" - LOGGER \(time()) " + string)
            break
        case .responses:
            //printStr(" - LOGGER \(time()) " + string)
            break
        case .requests:
            //let strSkiped = string.replacingOccurrences(of: "%2C", with: ",")
            //printStr(" - LOGGER \(time()) ➡️ REQUEST " + strSkiped.replacingOccurrences(of: APIConstants.dealsFields, with: "<skiped>"))
            printStr(string)
            break
        case .lifecycle:
            printStr(" - LOGGER \(time()) 💙 Lifecycle " + string)
            break
        case .gcd:
            //printStr(" - LOGGER \(time()) ⬛ GCD " + string)
            break
        case .localNotifications:
//            printStr(" - LOGGER \(time()) 📬 Local Notification " + string)
            break
        case .parserEntity:
           printStr(" - LOGGER \(time()) ✏️ Entity Parser " + string)
            break
        case .parserFactory:
//            printStr(" - LOGGER \(time()) 🏭 Factory Parsers " + string)
            break
        }
    }
    
    private func printStr(_ str: String) {
        guard self.enabled else {
            return
        }
        
        //#if DEBUG
            print(str)
        //#endif
    }

    private func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"

        return dateFormatter.string(from: Date())
    }
}
