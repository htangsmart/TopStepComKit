//
//  ForceSwiftLink.swift
//  TopStepComKit_Example
//
//  仅用于强制主 target 链接 Swift 运行时。
//  工程依赖了以 Swift 编写的静态库（ZIPFoundation、iOSDFULibrary），
//  但主 target 为纯 Objective-C，Xcode 默认不链接 Swift 运行时，
//  导致 swiftCompatibility50/51/56 等符号找不到。
//  加入本空文件后，Xcode 会自动补全 Swift 运行时相关链接。
//
//  This empty file forces the app target to link the Swift runtime,
//  resolving undefined swiftCompatibility* symbols from Swift static libs.
//

import Foundation
