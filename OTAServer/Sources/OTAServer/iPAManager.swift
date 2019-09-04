//
//  iPAManager.swift
//  OTAServer
//
//  Created by 张行 on 2019/9/4.
//

import Foundation
import Mustache

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

struct iPAManager {
    let path:String
    func load(filter:(IPAInfo) -> Bool) -> [IPAInfo] {
        guard let json = try? String(contentsOf: URL(fileURLWithPath: "\(path)/ipas.json"), encoding: String.Encoding.utf8) else {
            return []
        }
        guard let data = json.data(using: String.Encoding.utf8) else {
            return []
        }
        guard let list = try? JSONDecoder().decode([IPAInfo].self, from: data) else {
            return []
        }
        var filterList:[IPAInfo] = []
        for ipa in list {
            if filter(ipa) {
                filterList.append(ipa)
            }
        }
        return filterList
    }
    
    func filterAllBranch() -> String {
        var branchs:[String] = []
        let list = load { (ipa) -> Bool in
            let branch = ipa.branch ?? "developer"
            let isExit = branchs.contains(branch)
            if !isExit {
                branchs.append(branch)
            }
            return !isExit
        }
        var sourceList:[[String:Any]] = []
        for ipa in list {
            let branch = ipa.branch ?? "developer"
            var source = self.iPAListToObject(ipas: ipa)
            source["url"] = "/?page=1&branch=\(branch)"
            sourceList.append(source)
        }
        let source:[String:Any] = [
            "description" : "请选择分支",
            "list" : sourceList
        ]
        guard let template = try? Template(string: BranchTemplate) else {
            return ""
        }
        guard let body = try? template.render(source) else {
            return ""
        }
        return body
    }
    
    func filterAllVersion(branchName:String) -> String {
        var versions:[String] = []
        let list = load { (ipa) -> Bool in
            let branch = ipa.branch ?? "developer"
            let isNotExit = !versions.contains(ipa.version) && branch == branchName
            if isNotExit {
                versions.append(ipa.version)
            }
            return isNotExit
        }
        var sourceList:[[String:Any]] = []
        for ipa in list {
            var source = self.iPAListToObject(ipas: ipa)
            source["url"] = "/?page=2&branch=\(branchName)&version=\(ipa.version)"
            sourceList.append(source)
        }
        let source:[String:Any] = [
            "description" : "请选择版本号",
            "list" : sourceList
        ]
        guard let template = try? Template(string: VersionTemplate) else {
            return ""
        }
        guard let body = try? template.render(source) else {
            return ""
        }
        return body
    }
    
    func findAllDownloadIpas(branchName:String,version:String) -> String {
        let list = load { (ipa) -> Bool in
            let branch = ipa.branch ?? "developer"
            let isOK = ipa.version == version && branch == branchName
            return isOK
        }
        var sourceList:[[String:Any]] = []
        for ipa in list {
            var source = self.iPAListToObject(ipas: ipa)
            source["url"] = "/?page=3&branch=\(branchName)&version=\(ipa.version)&build=\(ipa.build)"
            sourceList.append(source)
        }
        let source:[String:Any] = [
            "description" : "请选择安装包",
            "list" : sourceList
        ]
        guard let template = try? Template(string: EvenmentTemplate) else {
            return ""
        }
        guard let body = try? template.render(source) else {
            return ""
        }
        return body
    }
    
    func getiPaInfo(branchName:String,version:String,build:Int) -> String {
        let list = load { (ipa) -> Bool in
            let branch = ipa.branch ?? "developer"
            let isOK = ipa.version == version &&  branch == branchName && ipa.build == build
            return isOK
        }
        var sourceList:[String:Any] = [:]
        for ipa in list {
            sourceList = self.iPAListToObject(ipas: ipa)
            if let config = findConfig(build: "\(ipa.build)") {
                sourceList["sha1"] = config["sha1"] as? String
                if let list = config["更新记录"] as? [String] {
                    var changeLog = list.joined(separator: "\n")
                    sourceList["changelog"] = changeLog
                }
                
            }
        }
        guard let template = try? Template(string: DetailTemplate) else {
            return ""
        }
        guard let body = try? template.render(sourceList) else {
            return ""
        }
        return body
    }
    
    func findConfig(build:String) -> [String:Any]? {
        let configPath = "\(path)/config"
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
    
    func iPAListToObject(ipas:IPAInfo) -> [String:Any] {
        guard let data = try? JSONEncoder().encode(ipas) else {
            return [:]
        }
        guard let source = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
            return [:]
        }
        return source
    }
}
