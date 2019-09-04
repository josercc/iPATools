
import PerfectHTTPServer
import PerfectHTTP

print("请输入根目录")
let path = readLine()
print("请输入端口号")
let port = readLine() ?? "8888"
var manager = iPAManager(path: path!)
let server = HTTPServer()
server.serverPort = UInt16(port) ?? 8888

var routes = Routes()
routes.add(uri: "/*") { (request, response) in
    let page = request.param(name: "page", defaultValue: "0")
    let branch = request.param(name: "branch") ?? "developer"
    let version = request.param(name: "version") ?? ""
    let build =  Int(request.param(name: "build") ?? "0") ?? 0
    if page == "0" {
        response.setBody(string: manager.filterAllBranch())
    } else if page == "1" {
        response.setBody(string: manager.filterAllVersion(branchName:branch))
    } else if page == "2" {
        response.setBody(string: manager.findAllDownloadIpas(branchName: branch, version: version))
    } else if page == "3" {
        response.setBody(string: manager.getiPaInfo(branchName: branch, version: version, build: build))
    }
    response.completed()
}
server.addRoutes(routes)

do {
    try server.start()
} catch {
    print("服务器请求失败");
}
