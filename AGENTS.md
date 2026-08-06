# Objective-C 开发规范 / OC Development Conventions

本文档约定 TopStepComKit 及相关工程中的 Objective-C 开发规范，便于团队统一、代码可读与维护。

> **详细命名/注释/格式/内存/单例/日志等 OC 规范（原 §1–§20）已移入技能 `.Codex/skills/oc-conventions/SKILL.md`**，
> 在编写或审查 OC 代码时自动加载，无需每次驻留上下文。以下保留必须常驻的项目信息与硬性约束。

---

## 二十一、项目前缀与基本信息

| 项目 | 说明 |
|------|------|
| **项目前缀** | `TS`（TopStep 对外接口与实现） |
| **iOS 最低版本** | iOS 12.0 |
| **当前版本** | 1.0.0-beta8 |
| **仓库地址** | https://github.com/htangsmart/TopStepComKit |
| **Swift 版本** | 5.0（部分子模块含 Swift 依赖） |

子模块保留前缀：`FitCloud`、`RTK`、`WM`、`SJ`、`NPK`——这些属于底层 SDK，**不使用 `TS` 前缀**。

---

## 二十二、技术栈与架构约定

### 22.1 SDK 模块结构

```
TopStepComKit-Git/Classes/
├── Foundation/     # 接口层 TopStepInterfaceKit + 工具层 TopStepToolKit
├── ComKit/         # SDK 主入口 TopStepComKit
├── FitCoreImp/     # FitCloud 硬件平台实现
├── FwCoreImp/      # Persimwear 硬件平台实现（仅真机 arm64）
├── SJCoreImp/      # SJWatch 硬件平台实现
└── NpkCoreImp/     # NPK 硬件平台实现
```

**调用链**：App → `TopStepComKit`（ComKit）→ `TopStepInterfaceKit` 接口层 → 各 CoreImp 实现层。

禁止 App 层直接引用 CoreImp 内部库（如 FitCloudKit），必须通过 ComKit 接口层调用。

### 22.2 Example 工程架构

- 采用 **MVC** 模式，每个功能对应一个 VC。
- 所有 VC 继承自 `TSBaseVC`。

```
Example/TopStepComKit-Git/Source/
├── AppDelegate/        # 应用入口（TSAppDelegate）
├── BaseVC/             # 基础类（TSBaseVC、TSRootVC、扫描/连接 VC）
│   ├── VC/
│   ├── Model/
│   └── View/
├── Ble/                # BLE 连接相关
├── Device/             # 设备功能，按功能模块分子目录
│   ├── AlarmClock/
│   ├── DataSync/
│   ├── HearRate/
│   └── ...（共 30+ 功能模块）
├── Home/               # 首页 Tab
└── Mine/               # 我的 Tab
```

### 22.3 新功能模块约定

在 `Source/Device/` 下新建同名子目录，文件命名为 `TS<功能>VC.h/.m`，继承 `TSBaseVC`。

---

## 二十三、常用构建命令

```bash
# 安装/更新依赖（必须在 Example/ 目录下执行）
cd Example && pod install

# 验证 podspec
pod lib lint TopStepComKit-Git.podspec --allow-warnings

# 清理编译缓存
xcodebuild clean \
  -workspace Example/TopStepComKit-Git.xcworkspace \
  -scheme TopStepComKit-Git_Example
```

> **重要**：打开工程必须使用 `Example/TopStepComKit-Git.xcworkspace`，不要直接打开 `.xcodeproj`。

CocoaPods 配置了两个源（Podfile 中顺序即优先级）：
1. `https://gitee.com/topstep/podspecs.git`（私有源，优先）
2. `https://github.com/CocoaPods/Specs.git`（官方源）

---

## 二十四、第三方库使用约束

| 子模块 | 依赖库 | 版本约束 | 说明 |
|--------|--------|---------|------|
| Foundation | SSZipArchive | 无锁定 | 压缩/解压 |
| FitCoreImp | iOSDFULibrary | ~> 4.13.0 | 固件升级 |
| FitCoreImp | zipzap | ~> 8.1.1 | zip 处理 |
| SJCoreImp | YYCategories | = 1.0.4 | 工具扩展 |
| SJCoreImp | ReactiveObjC | = 3.1.1 | 响应式（OC） |
| SJCoreImp | RxSwift / RxCocoa | = 6.8.0 | 响应式（Swift） |
| SJCoreImp | PromiseKit | = 8.1.1 | 异步链式 |
| SJCoreImp | HandyJSON | = 5.0.0 | JSON 解析 |
| SJCoreImp | SwiftyJSON | = 5.0.1 | JSON 工具 |
| SJCoreImp | SWCompression/TAR | 无锁定 | TAR 解压 |
| NpkCoreImp | Protobuf | 无锁定 | 协议序列化 |

**使用原则**：
- SJCoreImp 所有依赖均使用 `=` 锁定版本，**不得随意升级**，升级需全量回归测试。
- Example 工程**禁止**直接 `#import` CoreImp 子模块内部头文件，只允许通过 `TopStepComKit` 接口层使用。
- 按需引入子模块，避免集成全部 CoreImp（包体积与编译时间代价较大）。

---

## 二十五、项目特有注意事项

### 25.1 模拟器限制

`FwCoreImp`（Persimwear）**仅支持 arm64 真机**，不支持模拟器（x86_64 / arm64-simulator）。

Podfile 中已通过 xcconfig 排除：
```ruby
'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 x86_64'
```

如需在模拟器编译整个工程，**不能**在 Podfile 中引入 `FwCoreImp` 子模块。

### 25.2 BLE 回调线程

SDK 的 BLE 回调**不保证在主线程**，所有涉及 UI 更新的操作必须显式切换：

```objc
dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
});
```

### 25.3 SDK 初始化时序

- `TopStepComKit` 必须在 `application:didFinishLaunchingWithOptions:` 中完成初始化。
- 初始化完成前调用任何 SDK 接口会导致**静默失败或崩溃**，不会有明确报错。

### 25.4 链接标志

SDK 以 `static_framework = true` 发布，Podfile 使用 `use_frameworks!`。如遇符号找不到（`selector not recognized`、`unrecognized symbol`），先确认 xcconfig 中 `OTHER_LDFLAGS` 包含 `-ObjC`。

### 25.5 多平台实现并存

同一 App 可同时集成多个 CoreImp 子模块（如 `FitCoreImp` + `NpkCoreImp`），SDK 根据设备特征自动路由到对应实现，无需 App 层手动判断。
