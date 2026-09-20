# 已集成 FitCloudKit 的项目接入 TopStepComKit 指南

适用于已经通过 CocoaPods 集成 FitCloudKit、现在需要增加 TopStepComKit 的 iOS 项目。

请使用 **`develop_fitcloudkit_pod`** 分支。该分支通过 Pod 依赖 FitCloud 组件，使宿主 App 与 TopStepComKit 共用这些依赖，避免再次通过 TopStepComKit 引入同名框架。

| 项目 | 配置 |
| --- | --- |
| TopStepComKit 仓库 | [htangsmart/TopStepComKit](https://github.com/htangsmart/TopStepComKit) |
| 接入分支 | `develop_fitcloudkit_pod` |
| CocoaPods 名称 | `TopStepComKit-Git` |
| Objective-C 导入 | `#import <TopStepComKit/TopStepComKit.h>` |
| 本文对应版本 | `1.0.0-beta9`，提交 `4c237f4744442b89bc7f2869246da8986928546e` |
| 文档日期 | 2026-09-03 |

## 1. 接入前确认

- 本文以基础 Fit 功能为例，只选择 `ComKit` 和 `FitCoreImp`；`Foundation` 会自动引入。
- 已通过 Pod 集成 FitCloudKit 的项目使用上述专用分支。`main` 使用内置 FitCloud xcframework 的接入方式，不适用于本文场景。
- 当前分支的 FitCore 真机二进制最低系统版本为 **iOS 13.0**。虽然 podspec 的 FitCore 声明仍为 iOS 12.0，本文按实际二进制使用 iOS 13.0；需要 iOS 12 时，应先向 SDK 提供方获取兼容交付包。
- 使用 **arm64 真机**验证。当前分支的 podspec 排除了 `arm64` 和 `x86_64` 模拟器架构。
- 保留原项目的 `Podfile.lock`，记录原 FitCloud 组件来源、版本及 Git 提交，便于核对升级范围。

**共用 Pod 解决的是依赖重复问题。** 旧业务的连接状态、回调和绑定记录不会因此自动迁移到 TopStepComKit；运行时迁移见第 6 节。

## 2. 合并 Podfile

### 2.1 最小接入示例

将下面配置合并进现有 Podfile，替换 `YourAppTarget`。保留原项目的其他依赖、Specs 源和安装钩子。

已有同名 FitCloud Pod 时，沿用已有声明，不重复添加，也不要直接覆盖已有版本或提交约束。下面展示本 SDK 示例采用的 Git 来源；原项目使用其他来源或旧版本时，先确认与当前 TopStepComKit 二进制的兼容性，再决定是否调整。

```ruby
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'
use_frameworks!

target 'YourAppTarget' do
  # 已有同名依赖时沿用原声明，缺少的组件再补齐。
  pod 'FitCloudKit',
      :git => 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'
  pod 'FitCloudDFUKit',
      :git => 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'
  pod 'FitCloudWFKit',
      :git => 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'
  pod 'FitCloudNWFKit',
      :git => 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'

  pod 'TopStepComKit-Git',
      :git => 'https://github.com/htangsmart/TopStepComKit.git',
      :branch => 'develop_fitcloudkit_pod',
      :subspecs => ['ComKit','AIImp', 'FitCoreImp']
end
```

该示例使用 `use_frameworks!`。如果原项目使用 `use_frameworks! :linkage => :static`，按第 4.2 节合并动态依赖配置，不必直接替换整个项目的链接策略。

### 2.2 为什么需要四个 FitCloud Pod

当前 `FitCoreImp` 和 `FitAIImp` 都声明了以下四项依赖；已有项目只接入 `FitCloudKit` 时，仍需补齐其余组件的可解析来源。

| Pod | 用途与配套组件 |
| --- | --- |
| `FitCloudKit` | 核心通信框架及资源 |
| `FitCloudDFUKit` | 固件升级、RTK 系列组件及 `iOSDFULibrary` |
| `FitCloudWFKit` | 表盘相关框架及 `ABParTool` |
| `FitCloudNWFKit` | 表盘相关框架及 `zipzap` |

同名 Pod 需要由依赖解析器选定同一份来源和满足各方要求的版本。不要把 SDK 的 Git 仓库写成 `source 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'`；`source` 用于 Specs 源，SDK Git 地址放在 `:git` 中。[CocoaPods 配置说明](https://guides.cocoapods.org/syntax/podfile.html#pod)

如原项目还手动添加了同名 FitCloud/RTK 框架或资源，请移除已经由这些 Pod 提供的重复工程引用，让 CocoaPods 管理其链接和资源复制；先确认文件归属，不要删除无关依赖。

### 2.3 需要 Fit AI 时

将 TopStepComKit 声明中的模块选择改为：

```ruby
:subspecs => ['ComKit', 'FitAIImp']
```

这是替换第 2.1 节声明中的同名选项，不是新增一条 Pod 声明。`FitAIImp` 自动引入 `AIImp`；`FitCoreImp` 与 `FitAIImp` 都提供 `TopStepFitKit.framework`，必须二选一。

不要省略 `:subspecs`：当前默认模块还包括 `FitAIImp`、`NpkCoreImp` 和 `FwCoreImp`。AI 的业务授权及麦克风等权限，按所选 AI 能力另行接入。

## 3. 安装与版本管理

在宿主 App 的 Podfile 所在目录执行：

```bash
pod install
```

安装完成后，用宿主 App 的 **`.xcworkspace`** 打开项目。

检查 `Podfile.lock`：

- `TopStepComKit-Git` 的 `EXTERNAL SOURCES` 指向本文仓库和 `develop_fitcloudkit_pod` 分支。
- `CHECKOUT OPTIONS` 记录实际安装的 Git 提交；以这个提交判断安装内容，不能只看 `1.0.0-beta9`。
- 四个 FitCloud Pod 的版本、来源和提交符合本次接入方案；旧版本未被无意更换。
- 基础方案包含 `ComKit`、`Foundation`、`FitCoreImp`，不同时出现 `FitAIImp`。

后续需要获取分支上的新提交时，执行定向更新：

```bash
pod update TopStepComKit-Git
```

分支会继续变化；验证后将更新后的 `Podfile.lock` 纳入项目版本管理。不要为新增 TopStepComKit 删除整个锁文件或执行不带 Pod 名称的全量更新。[安装与更新的区别](https://guides.cocoapods.org/using/pod-install-vs-update.html)

## 4. 工程配置

### 4.1 蓝牙权限与链接设置

宿主 App 的 Info.plist 需要有效的蓝牙用途说明；原项目已有时保留并核对文案即可：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要使用蓝牙连接和管理您的智能穿戴设备</string>
```

此项用于 iOS 13 及以上的蓝牙权限说明。[Apple 配置说明](https://developer.apple.com/documentation/bundleresources/information-property-list/nsbluetoothalwaysusagedescription)

同时确认 App 的 `Other Linker Flags` 保留 `$(inherited)` 和 `-ObjC`，并继承 CocoaPods 生成的构建设置。框架和资源由 CocoaPods 集成，不再手动拖入一份。

### 4.2 原项目使用静态 Pod 链接时

当前交付包的 `TopStepToolKit.framework` 动态依赖 `SSZipArchive.framework`。对于 `use_frameworks! :linkage => :static` 的项目，需要让 `SSZipArchive` 以动态框架构建并随 App 嵌入，避免启动时出现 `Library not loaded`。

以下为基础 Fit 方案的配置。放在 Podfile 顶层；如果已经有 `pre_install`，将逻辑合并到现有钩子中：

```ruby
pre_install do |installer|
  installer.pod_targets.each do |pod_target|
    next unless pod_target.name == 'SSZipArchive'

    def pod_target.static_framework?
      false
    end

    def pod_target.build_type
      Pod::BuildType.dynamic_framework
    end
  end
end
```

选用 Fit AI 时，按文末附录合并 AI 依赖的动态链接和 `WCDB.swift` 配置。随 SDK 提供的 `Example/Podfile` 中，本机 `:path`、源码开发兼容头配置不属于用户二进制接入步骤，不要整体照搬。

## 5. 初始化 TopStepComKit

在现有 `application:didFinishLaunchingWithOptions:` 流程中发起一次初始化。旧业务已经运行时，先完成第 6 节的连接交接。**收到成功回调后，再开放扫描、连接和设备功能入口。**

在 AppDelegate.m 导入头文件：

```objc
#import <TopStepComKit/TopStepComKit.h>
```

将以下代码放入现有启动方法体，替换为 SDK 提供方为项目发放的 License：

```objc
// 当前公开接口的默认配置选择 Fit 平台。
TSKitConfigOptions *options = [TSKitConfigOptions defaultOption];
options.license = @"YOUR_TOPSTEP_LICENSE";
#if DEBUG
options.logConfig = [TSLogConfig debugConfig];
#else
options.logConfig = [TSLogConfig productionConfig];
#endif

[[TopStepComKit sharedInstance]
    initSDKWithConfigOptions:options
    completion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isSuccess) {
                TSLogError(@"[SDK] 初始化失败：%@/%ld",
                           error.domain, (long)error.code);
                // 展示初始化失败状态，保持设备操作入口不可用。
                return;
            }
            // 标记业务层初始化就绪，再允许用户扫描或连接设备。
        });
    }];
```

初始化成功只表示 SDK 就绪，不表示设备已经连接。既有 FitCloud 授权也不应直接当作 TopStepComKit License 使用；以 SDK 提供方交付的配置为准。

## 6. 迁移原有 FitCloud 连接逻辑

已有 FitCloud 业务可以分阶段迁移。对准备交给 TopStepComKit 管理的设备，先在原业务层停止扫描、自动重连和正在执行的设备任务，并完成旧连接的退出，再由 TopStepComKit 初始化、扫描和连接。

同一设备在同一时段使用一个连接管理入口，避免原业务与 TopStepComKit 同时连接、设置底层代理或发送指令。单纯安装成功，不能证明两套运行时逻辑可以并行控制同一设备。

| 原业务需要处理的内容 | 接入后的处理方式 |
| --- | --- |
| 扫描和设备选择 | 使用 `bleConnector`，保留其返回的 `TSPeripheral` |
| 连接与状态监听 | 使用 `connectWithPeripheral:param:completion:` 和 `registerConnectionStateDidChanged:` |
| 旧绑定用户 | 沿用当前用户稳定的业务 ID，核对与旧绑定身份一致 |
| 历史设备记录 | 根据已有设备标识重新建立 TopStepComKit 连接；不要假定旧缓存会自动接管 |
| 设备功能调用 | 通过 TopStepComKit 的公开接口访问，按设备能力判断是否支持 |

迁移时不要把“解绑”当作普通断开步骤。解绑会影响设备绑定关系；如果只是交接连接入口，应采用原接入方式支持的停止和断开流程。

## 7. 扫描与连接示例

以下代码在初始化成功后执行。示例仅展示 SDK 调用，设备列表保存、按钮状态和错误提示由宿主 App 实现；涉及 UI 的回调显式切回主线程。

### 7.1 扫描

```objc
id<TSBleConnectInterface> connector = [TopStepComKit sharedInstance].bleConnector;
[connector startSearchPeripheral:30.0
             discoverPeripheral:^(TSPeripheral *peripheral) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     // 保存 peripheral，并更新设备列表供用户选择。
                 });
             }
                     completion:^(TSScanCompletionReason reason, NSError *error) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (error) {
                                 TSLogError(@"[BLE] 扫描失败：%@/%ld",
                                            error.domain, (long)error.code);
                             }
                             // 根据 reason 更新扫描结束状态。
                         });
                     }];
```

离开扫描页时调用 `[connector stopSearchPeripheral]`。不要将原 FitCloud 的设备对象直接传给 TopStepComKit；连接时使用本次扫描返回的 `TSPeripheral`。

### 7.2 连接用户选中的设备

在业务类中增加下面的方法。`peripheral` 来自上一步扫描，`userIdentifier` 来自宿主 App 当前登录用户，不要每次连接生成新的随机 ID。

```objc
// 连接用户选中的设备，沿用当前业务用户身份。
- (void)connectPeripheral:(TSPeripheral *)peripheral
          userIdentifier:(NSString *)userIdentifier {
    if (!peripheral || userIdentifier.length == 0) {
        TSLogError(@"[BLE] 连接参数缺失");
        return;
    }

    TSPeripheralConnectParam *parameters =
        [TSPeripheralConnectParam paramWithUserId:userIdentifier];
    id<TSBleConnectInterface> connector = [TopStepComKit sharedInstance].bleConnector;
    [connector stopSearchPeripheral];
    [connector connectWithPeripheral:peripheral
                               param:parameters
                          completion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isSuccess) {
                TSLogError(@"[BLE] 连接失败：%@/%ld",
                           error.domain, (long)error.code);
                // 展示连接失败原因。
                return;
            }
            // 连接就绪，可通过 TopStepComKit 调用设备功能。
        });
    }];
}
```

扫码绑定流程使用 `paramWithUserId:authCode:`，传入设备二维码中的真实认证码；搜索连接或已绑定登录流程可不传 `authCode`。

连接 completion 只返回本次请求的最终结果。需要连接过程及后续断连通知时，注册 `registerConnectionStateDidChanged:`；`isConnected` 为 YES 才表示可以执行业务指令。全局连接监听由统一的业务连接层管理，再向页面分发。

## 8. 依赖版本核对

本文对应提交的 `Example/Podfile.lock` 记录如下版本，供排查版本差异时参考。这是示例工程的解析记录，不是对所有历史 FitCloud 版本的兼容承诺，也不要求无条件替换用户已有版本。

| 依赖 | 示例锁文件中的版本 |
| --- | --- |
| `FitCloudKit` | `1.3.2-beta.103` |
| `FitCloudDFUKit` | `1.3.4-beta.3` |
| `FitCloudWFKit` | `1.2.1-beta.6` |
| `FitCloudNWFKit` | `1.0.2-beta.1` |
| `iOSDFULibrary` | `4.11.1` |
| `zipzap` | `8.1.1` |

四个 FitCloud Pod 的 Git 提交均为 `b0b9d5baeb35e4ed7ecbcaa24761c109048ccbab`。

需要固定 TopStepComKit 交付内容时，可将其 Pod 声明的 `:branch` 替换为 SDK 提供方确认的 `:commit`，例如本文对应的 `4c237f4744442b89bc7f2869246da8986928546e`。FitCloud 组件使用各自确认的提交，不能混用两个仓库的提交号；同时保留锁文件。

例如，上述 `FitCloudDFUKit` 声明 `iOSDFULibrary ~> 4.11.0`，不能与宿主的 `~> 4.13.0` 同时满足。应先确认双方可以使用的依赖组合，再调整约束；只有确认旧约束多余时才移除，并按冲突涉及的 Pod 定向更新。

## 9. 常见问题

| 现象 | 排查与处理 |
| --- | --- |
| `duplicate symbols` 或同名 framework 冲突 | 核对使用的是 `develop_fitcloudkit_pod`；清理与 Pod 重复的手动框架引用；确认 `FitCoreImp`、`FitAIImp` 没有同时安装 |
| 提示同一 Pod 存在不同 external sources | 合并该 Pod 的声明，统一 Git 地址、分支或提交；检查不同 target、公共依赖块中的声明 |
| 找不到 `FitCloudDFUKit` 等 Podspec | 检查对应 Pod 的来源是否已声明、Git 仓库是否可访问；SDK Git 仓库应使用 `:git`，不应配置为 Specs 源 |
| `could not find compatible versions` | 对照冲突链和原锁文件核对版本；例如 `iOSDFULibrary` 的约束，按第 8 节处理 |
| 启动时报 `SSZipArchive.framework` 未加载 | 检查第 4.2 节动态构建配置及 CocoaPods 的框架嵌入脚本是否生效 |
| `selector not recognized` 或类别方法缺失 | 确认 `-ObjC`、`$(inherited)` 和 CocoaPods 构建配置生效，核对调用接口与实际安装版本 |
| 模拟器构建失败、最低 iOS 版本不匹配 | 使用 arm64 真机和 iOS 13.0 及以上配置；当前发布包不能按 podspec 的 iOS 12 声明直接认定兼容 |
| 初始化成功但无法连接 | 核对蓝牙权限、旧业务是否还在连接或重连、用户身份和认证参数；初始化成功不等于设备就绪 |
| 分支有新代码但本地未更新 | 查看锁文件实际提交，按需执行 `pod update TopStepComKit-Git` |

## 10. 接入完成自查

- `pod install` 成功，分支、模块和实际依赖版本符合预期。
- 使用 `.xcworkspace` 在真机编译、启动，无重复符号或动态库缺失错误。
- SDK 初始化成功；失败时不会继续发起设备指令。
- 可以扫描目标设备，并使用原业务用户身份完成连接。
- 可以读取设备信息，并验证本项目实际使用的功能，如数据同步、表盘或固件升级。
- 旧业务与 TopStepComKit 不会同时操作同一设备；断开、重连、重启 App 后的连接行为符合预期。
- 已核对旧用户绑定及业务数据，保存本次验证通过的 `Podfile.lock`。

以上检查由接入方在实际 App 与设备上完成。本文示例按对应提交的 Pod 配置和公开头文件核对，未代替宿主工程的编译与真机验证。

## 附录：Fit AI 的附加安装配置

仅选择 `FitAIImp` 时使用。若采用静态 Pod 链接，将第 4.2 节钩子的筛选条件改为以下名单，以匹配随 SDK 提供的示例配置：

```ruby
next unless ['SSZipArchive', 'AFNetworking', 'SocketRocket'].include?(pod_target.name)
```

同时将下列逻辑合并到现有 `post_install` 中；没有该钩子时再新增。它用于生成 `WCDB.swift` 的稳定 Swift 模块接口：

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |pod_target|
    next unless pod_target.name == 'WCDB.swift'

    pod_target.build_configurations.each do |configuration|
      configuration.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
```

## 配套资料

- [接入分支](https://github.com/htangsmart/TopStepComKit/tree/develop_fitcloudkit_pod)
- [本文对应的 Podspec](https://github.com/htangsmart/TopStepComKit/blob/4c237f4744442b89bc7f2869246da8986928546e/TopStepComKit-Git.podspec)
- [对应提交的 Example/Podfile](https://github.com/htangsmart/TopStepComKit/blob/4c237f4744442b89bc7f2869246da8986928546e/Example/Podfile)
- [对应提交的依赖锁文件](https://github.com/htangsmart/TopStepComKit/blob/4c237f4744442b89bc7f2869246da8986928546e/Example/Podfile.lock)
