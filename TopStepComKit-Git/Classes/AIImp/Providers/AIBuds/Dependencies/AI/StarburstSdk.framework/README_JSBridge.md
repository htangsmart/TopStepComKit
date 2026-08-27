# JSBridge 封装说明（SDK 内嵌、对 App 不暴露源码）

## 0. 如何编译 / 打包 JSBridge（已接入工程）

**JSBridge 已加入 StarburstSdk target**，无需再手动添加文件。

- **编译 StarburstSdk 即会编译 JSBridge**  
  在 Xcode 中选择 **StarburstSdk** scheme → **Product → Build**（或 ⌘B），会一起编译 JSBridge 的 Swift 代码并打进 `StarburstSdk.framework`。
- **打包 Framework**  
  选 **StarburstSdk** scheme → **Product → Archive**（或 菜单 Product → Archive），生成的 archive 里即包含带 JSBridge 的 framework；或直接 **Build** 后到 **Products** 目录下拷贝 `StarburstSdk.framework` 使用。

只要用上述方式打 StarburstSdk，JSBridge 会**自动**包含在 framework 里，无需单独“打包 JSBridge”。

---

## 1. 公开 API（App 仅能调用以下接口）

- **StarburstJSBridge.openBridgeWebView(url:from:)**  
  打开带 JSBridge 的 H5 容器页并 push 到当前导航栈。  
  `url` 传 nil 时优先加载主 bundle 或 SDK bundle 中的 `h5_assets/bridge_demo.html`。

- **StarburstJSBridge.createBridgeWebView(frame:configuration:)**  
  创建已注入 JSBridge 的 WebView，供 App 嵌入自定义容器（高级用法）。  
  返回类型为 `WKWebView`，不暴露内部 `StarburstWebView`。

其余类型（BridgeMessage、JsBridgeController、各 Handler 等）均为 **internal**，不暴露给 App。

---

## 2. 在 Xcode 中完成封装

### 2.1 把 JSBridge 加入 StarburstSdk target

1. 在工程导航中选中 **StarburstSdk** 组（与 Voice、Iot 同级）。
2. 右键 → **Add Files to "IOT"...**，选择 **StarburstSdk/JSBridge** 文件夹。
3. 勾选 **Copy items if needed**（若路径已在工程内可不勾选），**Add to targets** 只勾选 **StarburstSdk**，不要勾选 IOT。
4. 确保 **StarburstSdk/JSBridge/** 下所有 `.swift` 文件（含 Handlers 子目录）都出现在 StarburstSdk target 的 **Build Phases → Compile Sources** 中。

### 2.2 为 StarburstSdk 链接 WebKit

1. 选中工程 → 选中 **StarburstSdk** target → **Build Phases**。
2. 展开 **Link Binary With Libraries**，点击 **+**，添加 **WebKit.framework**（若已存在则跳过）。

### 2.3 从 IOT target 移除 JSBridge 源码

1. 在工程导航中展开 **IOT → Starburst → JSBridge**（原 App 侧 JSBridge）。
2. 选中该 **JSBridge** 组下所有 `.swift` 文件（可多选）。
3. 在右侧 **File Inspector** 的 **Target Membership** 中，**取消勾选 IOT**，仅保留未勾选或仅勾选 StarburstSdk（若你已把 SDK 下 JSBridge 加入 StarburstSdk，则这里只取消 IOT 即可）。
4. 这样 IOT 不再编译这些文件，App 侧不再包含 JSBridge 源码，仅通过链接 StarburstSdk.framework 使用。

### 2.4 App 侧调用方式

App 只需调用 SDK 公开 API，例如：

```swift
// Swift
var url: URL? = ...
StarburstJSBridge.openBridgeWebView(url: url, from: self)
```

```objc
// ObjC（需 #import <StarburstSdk/StarburstSdk.h>，并确保已生成 StarburstSdk-Swift.h）
[StarburstJSBridge openBridgeWebViewWithUrl:url from:self];
```

### 2.5 H5 资源（可选）

- **方案 A**：继续由 App 提供：在 IOT 的 **Copy Bundle Resources** 中保留 **h5_assets**，`url` 传 nil 时 SDK 会先查 `Bundle.main`，可找到 App 的 `h5_assets/bridge_demo.html`。
- **方案 B**：由 SDK 提供：把 **h5_assets** 拖入 StarburstSdk target 的 **Copy Bundle Resources**，SDK 会从 `Bundle(for: StarburstJSBridge.self)` 查找默认页。

---

## 3. 交付形态

- 对外仅提供 **StarburstSdk.framework**（或 XCFramework）及公开头文件。
- JSBridge 实现全部在 SDK 内，App 无法看到 BridgeMessage、Handler 等实现，仅能通过 **StarburstJSBridge** 的上述两个接口使用能力。
