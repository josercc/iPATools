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
    
    private struct IPAToolName {
        static var rootPath:String = "rootPath"
        static var server:String = "server"
        static var githubRepo:String = "githubRepo"
        static var identifier:String = "identifier"
//        static var port:String = "port"
        static var githubUser:String = "githubUser"
    }
    
    var rootPath:String = "/Applications/MAMP/htdocs"
    var server:String = "http://0.0.0.0:8888/"
    var githubRoot:String = "https://raw.githubusercontent.com/"
    var githubRepo:String = "iPAToolPlist"
    var identifier:String = "com.xxxxxxxxxx.identifier"
//    var port:String = "8888"
    var githubUser:String = ""
    /// 是否可以解析命令
    ///
    /// - Returns: 如果是YES代表可以解析 如果是NO代表不可以解析
    func canParseCommand() -> Bool {
        guard CommandLine.argc >= 2 else {
            return false
        }
        /// 判断命令是否被程序支持
        guard ["rootPath","server","githubRepo","identifier","githubUser","public","--help","--configuration"].contains(CommandLine.arguments[1]) else {
            return false
        }
        
        getLocalValue()
        
        if canParsePublic() {
            return true
        }
        
        if checkOtherCommand(command: "rootPath", key: IPAToolName.rootPath) {
            return true
        }
        
        if checkOtherCommand(command: "server", key: IPAToolName.server) {
            return true
        }
        
        if checkOtherCommand(command: "githubRepo", key: IPAToolName.githubRepo) {
            return true
        }
        
        if checkOtherCommand(command: "identifier", key: IPAToolName.identifier) {
            return true
        }
        
        if checkOtherCommand(command: "githubUser", key: IPAToolName.githubUser) {
            return true
        }
        
        if checkHelp() {
            return true
        }
        
        if checkConfigurationValue() {
            return true
        }
        
        return false
    }
    
    func getLocalValue() {
        rootPath = setValue(key: IPAToolName.rootPath, defaultValue: rootPath)
        server = setValue(key: IPAToolName.server, defaultValue: server)
        githubRepo = setValue(key: IPAToolName.githubRepo, defaultValue: githubRepo)
        identifier = setValue(key: IPAToolName.identifier, defaultValue: identifier)
        githubUser = setValue(key: IPAToolName.githubUser, defaultValue: githubUser)
    }
    
    func checkConfigurationValue() -> Bool {
        guard CommandLine.arguments[1] == "--configuration" else {
            return false
        }
        let log = "rootPath:\(rootPath)\n"
        + "server:\(server)\n"
        + "githubRepo:\(githubRepo)\n"
        + "identifier:\(identifier)\n"
        + "githubUser:\(githubUser)\n"
        print(log)
        return true
    }
    
    func checkOtherCommand(command:String, key:String) -> Bool {
        guard CommandLine.argc == 3 else {
            return false
        }
        guard CommandLine.arguments[1] == command  else {
            return false
        }
        UserDefaults.standard.set(CommandLine.arguments[2], forKey: key)
        return true
    }
    
    func setValue(key:String, defaultValue:String) -> String {
        guard let value = UserDefaults.standard.object(forKey: key) as? String else {
            return defaultValue
        }
        guard value.count > 0 else {
            return defaultValue
        }
        return value
    }
    
    func checkHelp() -> Bool {
        guard CommandLine.arguments[1] == "--help" else {
            return false
        }
        let printInfo = "iPATools命令请使用下列命令:\n"
            + "public 发布本地的IPA的安装文件到指定目录并生成对应的index.html安装文件\n"
            + "rootPath 包含IPA文件和Plist文件的主目录 默认为/Applications/MAMP/htdocs\n"
            + "server 设置服务器的地址默认为http://0.0.0.0:8888/\n"
            + "githubUser * 设置github 托管Plist库用户名或者组织名称默认不存在\n"
            + "githubRepo 设置github 托管Plist库的库名称默认为iPAToolPlist默认为iPAToolPlist\n"
            + "identifier 设置APP的标识符默认为com.xxxxxxxxxx.identifier 不设置不影响安装会在安装之后覆盖之前的\n"
            + "--help 获取帮助\n"
            + "--configuration 查看当前的配置\n"
        print(printInfo)
        return true
    }
    
    /// 命令是否可以发布
    ///
    /// - Returns: 如果是YES代表可以 如果是NO代表不可以
    func canParsePublic() -> Bool {
        guard CommandLine.arguments[1] == "public" else {
            return false
        }
        guard checkConfiguration() else {
            print("请通过iPATools githubUser设置存在github库的用户名称或者组织名称")
            return false
        }
        publicIpa()
        return true
    }
    
    /// 检查配置是否可以发布
    ///
    /// - Returns: 如果是true代表可以发布 如果是false代表不可以发布
    func checkConfiguration() -> Bool{
        guard let user = UserDefaults.standard.object(forKey: IPAToolName.githubUser) as? String else {
            return false
        }
        guard user.count > 0 else {
            return false
        }
        githubUser = user
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
                "{ipa-url}":"\(server)ipa/\(info.ipaName)",
                "{display-image}":"\(server)57x57.png",
                "{full-size-image}":"\(server)512x512.png",
                "{bundle-version}":"\(info.version)",
                "{title}":"\(info.name)",
                "{bundle-identifier}":identifier,
            ]
            
            for dic in replace {
                content = content.replacingOccurrences(of: dic.key, with: dic.value)
            }
            
            let file = "\(rootPath)/\(githubRepo)/plist/\(info.ipaName.replacingOccurrences(of: ".ipa", with: ".plist"))"
            
            try? content.write(toFile: file, atomically: true, encoding: String.Encoding.utf8)
            
            var envermentName = "测试环境"
            if info.enverment == "Release" {
                envermentName = "正式环境"
            }
            var name = "\(info.name)_\(envermentName)_\(info.version)_\(info.time)"
            if let branch = info.branch {
                name = "\(name)(\(branch))"
            }
            let item = "<h1>\(name)</h1><a href=\'itms-services://?action=download-manifest&url=\(githubRoot)\(githubUser)/\(githubRepo)/master/plist/\(info.ipaName.replacingOccurrences(of: ".ipa", with: ".plist"))'><img src=\"./install.png\" alt=\"立即安装\" ></a>"
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
        for var content in contents {
            let paths = content.components(separatedBy: ".")
            guard let laste = paths.last else {
                continue
            }
            guard laste == "ipa" else {
                continue
            }
            let start = content.range(of: "[")
            let end = content.range(of: "]", options: String.CompareOptions.backwards, range: nil, locale: nil)
            var info = IPAInfo()
            if start != nil && end != nil {
                let branchTempSub = content[start?.lowerBound..<end?.upperBound]
                let branchTemp = String(branchTempSub)
                var branch = branchTemp?.replacingOccurrences(of: "[", with: "")
                branch = branch?.replacingOccurrences(of: "]", with: "")
                info.branch = branch
                content = content.replacingOccurrences(of: "_\(branchTemp!)", with: "")
            }
            let items = content.components(separatedBy: "_")
            guard items.count == 4 else {
                continue
            }
            
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
        formatter.dateFormat = "yyyy年MM月dd日HH时mm分ss秒"
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
    var branch:String?
}
