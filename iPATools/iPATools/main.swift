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
    print("请输入ipaTools --help查询命令！")
}

