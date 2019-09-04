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
        static var githubUser:String = "githubUser"
    }
    
    var rootPath:String = "/Applications/MAMP/htdocs"
    var server:String = "http://0.0.0.0:8888/"
    var githubRoot:String = "https://raw.githubusercontent.com/"
    var githubRepo:String = "iPAToolPlist"
    var identifier:String = "com.xxxxxxxxxx.identifier"
    var githubUser:String = ""
    /// 是否可以解析命令
    ///
    /// - Returns: 如果是YES代表可以解析 如果是NO代表不可以解析
    func canParseCommand() -> Bool {
        guard CommandLine.argc >= 2 else {
            return false
        }
        /// 判断命令是否被程序支持
        guard ["rootPath","server","githubRepo","identifier","githubUser","public","--help","--configuration","configiPA", "getSha","removeOldVersion"].contains(CommandLine.arguments[1]) else {
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
        
        if configIpa() {
            return true
        }
        
        if getSha1() {
            return true
        }
        
        if removeOldVersion() {
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
            + "removeOldVersion 移除老版本"
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
        for var info in list {
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
            let name = "\(info.name)_\(envermentName)_\(info.version)_\(info.time)"
            var infoContent = ""
            if let config = findConfig(build: "\(info.build)") {
                guard let sort = config["sort_Key"] as? [String] else {
                    break
                }
                for name in sort {
                    if name != "更新记录" {
                        if let value = config[name] as? String {
                            infoContent += "<h3 style=\"color:red;\">\(name):\(value)</h3>"
                        }
                    } else {
                        if let value = config[name] as? [String] {
                            infoContent += "<h3 style=\"color:red\">\(name):</h3>"
                            for log in value {
                                infoContent += "<h4 style=\"color:gray\">\(log)</h3>"
                            }
                        }
                    }
                }
            }
            let downloadURL = "\(githubRoot)\(githubUser)/\(githubRepo)/master/plist/\(info.ipaName.replacingOccurrences(of: ".ipa", with: ".plist"))"
            var item = "<h1>\(name)</h1><a href=\'itms-services://?action=download-manifest&url=\(githubRoot)\(githubUser)/\(githubRepo)/master/plist/\(info.ipaName.replacingOccurrences(of: ".ipa", with: ".plist"))'><img src=\"./install.png\" alt=\"立即安装\" ></a>"
            if infoContent.count > 0 {
                item = "<h1>\(name)</h1>\(infoContent)<a href=\'itms-services://?action=download-manifest&url=\(githubRoot)\(githubUser)/\(githubRepo)/master/plist/\(info.ipaName.replacingOccurrences(of: ".ipa", with: ".plist"))'><img src=\"./install.png\" alt=\"立即安装\" ></a>"
            }
            body += item
            
        }
        let html:String = "<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title></title></head><body>\(body)</body></html>"
        try? html.write(toFile: "\(rootPath)/index.html", atomically: true, encoding: String.Encoding.utf8)
        
        saveIpaListInJson(ipas: list)
    }
    
    func saveIpaListInJson(ipas:[IPAInfo]) {
        guard let data = try? JSONEncoder().encode(ipas) else {
            print("‼️生成安装包JSON失败")
            return
        }
        guard let json = String(data: data, encoding: String.Encoding.utf8) else {
            print("‼️生成安装包JSON失败")
            return
        }
        let jsonPath = "\(rootPath)/ipas.json"
        do {
            try json.write(to: URL(fileURLWithPath: jsonPath), atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("‼️安装包JSON写出失败")
        }
    }
    
    func findAllIpa() -> [IPAInfo] {
        var list = findIpa(path: "\(rootPath)/ipa",enverment:["Debug","Release","appstore","AppStore"])
        list = list.sorted(by: { (left, right) -> Bool in
            left.build >= right.build
        })
        return list
    }
    
    func findConfig(build:String) -> [String:Any]? {
        let configPath = "\(rootPath)/config"
        var config:[String:Any]?
        do {
            let list = try FileManager.default.contentsOfDirectory(atPath: configPath)
            for name in list {
                guard name == "\(build).json" else {
                    continue
                }
                let filePath = "\(configPath)/\(name)"
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                    do {
                        config = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : Any]
                    } catch {
                        print("❤️读取配置JSON信息失败")
                    }
                } catch {
                    print("❤️读取配置JSON信息失败")
                }
            }
            
        } catch {
            print("💛获取配置列表失败")
        }
        return config
    }
    
    func findIpa(path:String, enverment:[String] = ["Debug","Release"]) -> [IPAInfo] {
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
            let start = content.range(of: "@")
            let end = content.range(of: "@", options: String.CompareOptions.backwards, range: nil, locale: nil)
            var info = IPAInfo()
            if start != nil && end != nil {
                let branchTempSub = content[start!.lowerBound..<end!.upperBound]
                let branchTemp = String(branchTempSub)
                var branch = branchTemp.replacingOccurrences(of: "@", with: "")
                branch = branch.replacingOccurrences(of: "@", with: "")
                info.branch = branch
                content = content.replacingOccurrences(of: "_\(branchTemp)", with: "")
            }
            let items = content.components(separatedBy: "_")
            guard items.count == 4 else {
                continue
            }
            
            info.name = items[0]
            info.enverment = items[1]
            if !enverment.contains(info.enverment) {
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
            let downloadURL = "\(githubRoot)\(githubUser)/\(githubRepo)/master/plist/\(info.ipaName.replacingOccurrences(of: ".ipa", with: ".plist"))"
            info.downloadURL = "itms-services://?action=download-manifest&url=\(downloadURL)"
            if let config = findConfig(build: "\(info.build)") {
                info.branch = config["分支名称"] as? String
            }
            list.append(info)
        }
        return list
    }
    
    func configIpa() -> Bool {
        guard CommandLine.argc >= 2 else {
            return false
        }
        let command = CommandLine.arguments[1]
        guard command == "configiPA" else {
            return false
        }
        var config:[String:Any] = [:]
        var sort:[String] = []
        for argument in CommandLine.arguments.enumerated() {
            if argument.offset <= 1 {
                continue
            }
            let arc = argument.element
            var list = arc.components(separatedBy: "=")
            if list.count <= 1 {
                continue
            }
            let key = list.first
            list.removeFirst()
            let value = list.joined(separator: "=")
            guard let key1 = key else {
                continue
            }
            config[key1] = value
            if key1 != "build" {
                sort.append(key1)
            }
        }
        config["sort_Key"] = sort
        
        if let changeLog = config["更新记录"] as? String {
            var logs:[String] = []
            let changelogList = spliteChangeLog(changeLog: changeLog)
            var upSha1:String? = nil
            if let branch = config["分支名称"] as? String {
                upSha1 = upSuccessSha1(branch: branch)
            }
            for log in changelogList {
                if upSha1 != nil && log.sha1.range(of: upSha1!) != nil {
                    break
                }
                logs.append(log.log)
            }
            if logs.count == 0 {
                logs.append(changelogList.first!.log)
            }
            config["更新记录"] = logs
        }
        
        let configPath = "\(rootPath)/config"
        var isDirectory = ObjCBool(false)
        FileManager.default.fileExists(atPath: configPath, isDirectory: &isDirectory)
        if !isDirectory.boolValue {
            do {
                try FileManager.default.createDirectory(atPath: configPath, withIntermediateDirectories: true, attributes: nil)
                saveConfig(config: config, configPath: configPath)
            } catch {
                print("❤️创建目录\(configPath)失败")
            }
        } else {
            saveConfig(config: config, configPath: configPath)
        }
        return true
    }
    
    func spliteChangeLog(changeLog:String) -> [(sha1:String, log:String)] {
        var list:[(sha1:String, log:String)] = []
        let logList = changeLog.components(separatedBy: "\n")
        for log in logList {
            var logInfo = log.components(separatedBy: " ")
            guard let sha1 = logInfo.first else {
                continue
            }
            logInfo.removeFirst()
            let log = logInfo.joined(separator: " ")
            list.append((sha1:sha1, log:log))
        }
        return list
    }
    
    func saveConfig(config:[String:Any], configPath:String) {
        let buildKey = "build"
        guard let build = config[buildKey] else {
            print("❤️缺少build号无法保存")
            return
        }
        do {
            let json = try JSONSerialization.data(withJSONObject: config, options: JSONSerialization.WritingOptions.prettyPrinted)
            guard let jsonString = String(data: json, encoding: String.Encoding.utf8) else {
                print("❤️转成JSON字符串失败")
                return
            }
            do {
                try jsonString.write(toFile: "\(configPath)/\(build).json", atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("❤️保存配置文件失败!\(error.localizedDescription)")
            }
        } catch {
            print("❤️JSON序列化失败!\(error.localizedDescription)")
        }
    }
    
    func getSha1() -> Bool {
        guard CommandLine.argc == 3 else {
            return false
        }
        guard CommandLine.arguments[1] == "getSha" else {
            return false
        }
        let branchName = CommandLine.arguments[2]
        guard let sha1 = upSuccessSha1(branch: branchName) else {
            return true
        }
        print(sha1)
        return true
    }
    
    func removeOldVersion() -> Bool {
        guard CommandLine.argc == 3 else {
            return false
        }
        guard CommandLine.arguments[1] == "removeOldVersion" else {
            return false
        }
        let nowVersion = CommandLine.arguments[2]
        let allIpa = findAllIpa()
        var versionIpaList:[String:IPAInfo] = [:]
        for ipa in allIpa {
            if !compareVersion(old: ipa.version, new: nowVersion) {
                print("version=\(ipa.version)")
                if versionIpaList[ipa.version] != nil || ipa.enverment == "appstore" || ipa.enverment == "AppStore" || ipa.enverment == "Release" {
                    let ipaPath = "\(rootPath)/ipa/\(ipa.name)_\(ipa.enverment)_\(ipa.version)_\(ipa.build).ipa"
                    let dsym = "\(rootPath)/ipa/\(ipa.name)_\(ipa.enverment)_\(ipa.version)_\(ipa.build).app.dSYM.zip"
                    let removePaths = [ipaPath,dsym]
                    for path in removePaths {
                        print("path=\(path)")
                        if FileManager.default.fileExists(atPath: path) {
                            try? FileManager.default.removeItem(atPath: path)
                        }
                    }
                } else {
                    versionIpaList[ipa.version] = ipa
                }
            } else {
                print(ipa)
            }
        }
        return true
    }
    
    func compareVersion(old:String, new:String) -> Bool {
        let oldVersions = old.components(separatedBy: ".")
        let newVersions = new.components(separatedBy: ".")
        for version in oldVersions.enumerated() {
            if newVersions.count > version.offset {
                let newVersion = newVersions[version.offset]
                guard let oldVersionInt = Int(version.element) else {
                    return true
                }
                
                guard let newVersionInt = Int(newVersion) else {
                    return true
                }
                if oldVersionInt > newVersionInt {
                    return true
                } else if oldVersionInt < newVersionInt {
                    return false
                } else {
                    continue
                }
            } else {
                return true
            }
        }
        return false
    }
    
    func upSuccessSha1(branch:String) -> String? {
        let configPath = "\(rootPath)/config"
        var sha1:String? = ""
        var timeIndex = 0
        do {
            let list = try FileManager.default.contentsOfDirectory(atPath: configPath)
            let ipaPath = "\(rootPath)/ipa"
            guard let ipaList = try? FileManager.default.contentsOfDirectory(atPath: ipaPath) else {
                return sha1
            }
            for name in list {
                guard let build = name.components(separatedBy: ".json").first else {
                    continue
                }
                guard let config = findConfig(build: build) else {
                    continue
                }
                guard let branch = config["分支名称"] as? String else {
                    continue
                }
                guard let buildIndex = Int(build) else {
                    continue
                }
                if branch == branch && buildIndex > timeIndex {
                    for ipaName in ipaList {
                        if ipaName.range(of: build) != nil {
                            sha1 = config["sha1"] as? String
                            timeIndex = buildIndex
                        }
                    }
                }
            }
        } catch {
            
        }
        return sha1
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

struct IPAInfo : Codable {
    /// 名字
    var name:String = ""
    /// 环境
    var enverment:String = ""
    /// 版本
    var version:String = ""
    /// 编译版本
    var build:Int = 0
    /// iPa的名称
    var ipaName:String = ""
    /// 时间戳
    var time:String = ""
    ///分支
    var branch:String?
    /// 下载地址
    var downloadURL:String = ""
}
