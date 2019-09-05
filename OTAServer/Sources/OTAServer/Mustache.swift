//
//  Mustache.swift
//  OTAServer
//
//  Created by 张行 on 2019/9/4.
//

import Foundation

let BranchTemplate = """
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title></title>
        <link rel="stylesheet" href="//res.wx.qq.com/open/libs/weui/1.1.3/weui.min.css" />
        <meta name="viewport" content="width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
    </head>
    <body>
        <a href="/" class="weui-btn weui-btn_primary style="width: 95%;">回到首页</a>
        <div class="weui-cells__title">{{description}}</div>
        <div class="weui-cells">
            {{#list}}
            <a class="weui-cell weui-cell_access" href="{{url}}">
                <div class="weui-cell__bd">
                    <p>{{branch}}</p>
                </div>
                <div class="weui-cell__ft">
                </div>
            </a>
            {{/list}}
        </div>
    </body>
</html>
"""

let VersionTemplate = """
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title></title>
        <link rel="stylesheet" href="//res.wx.qq.com/open/libs/weui/1.1.3/weui.min.css" />
        <meta name="viewport" content="width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
    </head>
    <body>
        <a href="/" class="weui-btn weui-btn_primary style="width: 95%;">回到首页</a>
        <div class="weui-cells__title">{{description}}</div>
        <div class="weui-cells">
            {{#list}}
            <a class="weui-cell weui-cell_access" href="{{url}}">
                <div class="weui-cell__bd">
                    <p>{{version}}</p>
                </div>
                <div class="weui-cell__ft">
                </div>
            </a>
            {{/list}}
        </div>
    </body>
</html>
"""


let EvenmentTemplate = """
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title></title>
        <link rel="stylesheet" href="//res.wx.qq.com/open/libs/weui/1.1.3/weui.min.css" />
        <meta name="viewport" content="width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
    </head>
    <body>
        <a href="/" class="weui-btn weui-btn_primary style="width: 95%;">回到首页</a>
        <div class="weui-cells__title">{{description}}</div>
        <div class="weui-cells">
            {{#list}}
            <a class="weui-cell weui-cell_access" href="{{url}}">
                <div class="weui-cell__bd">
                    <p>{{time}}</p>
                </div>
                <div class="weui-cell__ft">{{enverment}}</div>
            </a>
            {{/list}}
        </div>
    </body>
</html>
"""

let DetailTemplate = """
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title></title>
        <link rel="stylesheet" href="//res.wx.qq.com/open/libs/weui/1.1.3/weui.min.css" />
        <meta name="viewport" content="width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
    </head>
    <body>
        <a href="/" class="weui-btn weui-btn_primary style="width: 95%;">回到首页</a>
        <div class="weui-tab">
            <div class="weui-tab__panel">
                <div class="weui-panel weui-panel_access">
                    <div class="weui-panel__hd">安装包详情</div>
                    <div class="weui-panel__bd">
                        <div class="weui-media-box weui-media-box_text">
                            <h4 class="weui-media-box__title">环境</h4>
                            <p class="weui-media-box__desc">{{enverment}}</p>
                        </div>
                        <div class="weui-media-box weui-media-box_text">
                            <h4 class="weui-media-box__title">版本</h4>
                            <p class="weui-media-box__desc">{{version}}</p>
                        </div>
                        <div class="weui-media-box weui-media-box_text">
                            <h4 class="weui-media-box__title">Build号</h4>
                            <p class="weui-media-box__desc">{{build}}</p>
                        </div>
                        <div class="weui-media-box weui-media-box_text">
                            <h4 class="weui-media-box__title">iPA名称</h4>
                            <p class="weui-media-box__desc">{{ipaName}}</p>
                        </div>
                        <div class="weui-media-box weui-media-box_text">
                            <h4 class="weui-media-box__title">时间</h4>
                            <p class="weui-media-box__desc">{{time}}</p>
                        </div>
                        <div class="weui-media-box weui-media-box_text">
                            <h4 class="weui-media-box__title">分支</h4>
                            <p class="weui-media-box__desc">{{branch}}</p>
                        </div>
                        <div class="weui-media-box weui-media-box_text">
                            <h4 class="weui-media-box__title">Sha1值</h4>
                            <p class="weui-media-box__desc">{{sha1}}</p>
                        </div>
                        <div class="weui-media-box weui-media-box_text">
                            <h4 class="weui-media-box__title">更新记录</h4>
                            <p class="weui-media-box__desc">{{changelog}}</p>
                        </div>
                    </div>
                    
                </div>
            </div>
            <div class="weui-tabbar">
                <a href="{{downloadURL}}" class="weui-btn weui-btn_warn">在线安装</a>
            </div>
        </div>
    </body>
</html>
"""
