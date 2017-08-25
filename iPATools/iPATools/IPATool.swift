//
//  IPATool.swift
//  iPATools
//
//  Created by 张行 on 2017/8/24.
//  Copyright © 2017年 张行. All rights reserved.
//

import Foundation

/// IPATool解析命令行
class IPATool {
    let rootPath:String = "/Applications/MAMP/htdocs"
    let server:String = "http://10.33.22.80"
    let githubPath:String = "https://raw.githubusercontent.com/josercc/iPATool-Plist"
    let identifier:String = "com.globalegrow.gearbest"
    let port:String = "8888"
    /// 是否可以解析命令
    ///
    /// - Returns: 如果是YES代表可以解析 如果是NO代表不可以解析
    func canParseCommand() -> Bool {
        guard CommandLine.argc == 2 else {
            return false
        }
        
        guard canParsePublic() else {
            return false
        }
        
        return true
    }
    
    /// 命令是否可以发布
    ///
    /// - Returns: 如果是YES代表可以 如果是NO代表不可以
    func canParsePublic() -> Bool {
        guard CommandLine.arguments[1] == "public" else {
            return false
        }
        publicIpa()
        return true
    }
    
    func publicIpa() {
        var list = findIpa(path: "\(rootPath)/ipa")
        list = list.sorted(by: { (left, right) -> Bool in
            left.build >= right.build
        })
        
        var body = ""
        for info in list {
            guard var content = try? String.init(contentsOfFile: "\(rootPath)/manifest.plist") else {
                continue
            }
            let replace:[String:String] = [
                "{ipa-url}":"\(server):\(port)/ipa/\(info.ipaName)",
                "{display-image}":"\(server):\(port)/57x57.png",
                "{full-size-image}":"\(server):\(port)/512x512.png",
                "{bundle-version}":"\(info.version)",
                "{title}":"\(info.name)",
                "{bundle-identifier}":identifier,
            ]
            
            for dic in replace {
                content = content.replacingOccurrences(of: dic.key, with: dic.value)
            }
            
            let file = "\(rootPath)/iPAToolPlist/plist/\(info.ipaName.replacingOccurrences(of: ".ipa", with: ".plist"))"
            
            try? content.write(toFile: file, atomically: true, encoding: String.Encoding.utf8)
            
            var envermentName = "测试环境"
            if info.enverment == "Release" {
                envermentName = "正式环境"
            }
            
            let item = "<h1>\(info.name)_\(envermentName)_\(info.version)_\(info.build))</h1><a href=\'itms-services://?action=download-manifest&url=\(githubPath)/master/plist/\(info.ipaName.replacingOccurrences(of: ".ipa", with: ".plist"))'><img src=\"./install.png\" alt=\"立即安装\" ></a>"
            body += item
            
        }
        let html:String = "<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title></title></head><body>\(body)</body></html>"
        try? html.write(toFile: "\(rootPath)/index.html", atomically: true, encoding: String.Encoding.utf8)
    }
    
    func findIpa(path:String) -> [IPAInfo] {
        var list:[IPAInfo] = []
        guard FileManager.default.fileExists(atPath: path, isDirectory: nil) else {
            return list
        }
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            return list
        }
        for content in contents {
            let paths = content.components(separatedBy: ".")
            guard let laste = paths.last else {
                continue
            }
            guard laste == "ipa" else {
                continue
            }
            let items = content.components(separatedBy: "_")
            guard items.count == 4 else {
                continue
            }
            var info = IPAInfo()
            info.name = items[0]
            info.enverment = items[1]
            guard info.enverment == "Debug" || info.enverment == "Release" else {
                continue
            }
            info.version = items[2]
            info.ipaName = content
            let number = buildNumber(str: items[3])
            guard number > 0 else {
                continue
            }
            info.build = number
            guard let time = buildTime(time: number) else {
                continue
            }
            info.time = time
            list.append(info)
        }
        return list
    }
    
    func buildNumber(str:String) -> Int {
        let number = str.replacingOccurrences(of: ".ipa", with: "")
        return Int(number) ?? 0
    }
    
    func buildTime(time:Int) -> String? {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd天HH时mm分ss秒"
        return formatter.string(from: date)
    }
}

struct IPAInfo {
    var name:String = ""
    var enverment:String = ""
    var version:String = ""
    var build:Int = 0
    var ipaName:String = ""
    var time:String = ""
}
