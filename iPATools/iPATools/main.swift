//
//  main.swift
//  iPATools
//
//  Created by 张行 on 2017/8/24.
//  Copyright © 2017年 张行. All rights reserved.
//

import Foundation

let tool = IPATool()
if !tool.canParseCommand() {
    print("更多信息请输入 iPATools --help")
}

