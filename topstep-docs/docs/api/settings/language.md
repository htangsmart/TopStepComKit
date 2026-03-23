---
sidebar_position: 3
title: 语言设置
---

# 语言设置（TSLanguage）

TSLanguage 模块提供了完整的设备语言管理功能，包括获取支持的语言列表、查询和设置当前设备语言，以及监听语言变化事件。

## 前提条件

- iOS 设备已连接到 TopStepComKit SDK
- 已成功初始化 SDK 并获得 `TSLanguageInterface` 实例
- 设备固件版本支持语言管理功能

## 数据模型

### TSLanguageModel

| 属性名 | 类型 | 说明 |
|-------|------|------|
| `type` | `TSLanguageType` | 语言类型枚举值（如 `TSLanguage_ENGLISH` 表示英语） |
| `code` | `NSString *` | 语言代码，遵循 ISO 639-1 标准（如 "en" 表示英语，"zh" 表示中文） |
| `nativeName` | `NSString *` | 语言的本地名称（如英语显示为 "English"，中文显示为 "中文"） |
| `chineseName` | `NSString *` | 语言的中文名称（如 "英语"、"中文"） |

## 枚举与常量

### TSLanguageType

| 枚举值 | 数值 | 说明 |
|--------|------|------|
| `TSLanguage_UNKNOW` | 0 | 未设置 |
| `TSLanguage_CHINESESIMPLIFIED` | 1 | 简体中文 |
| `TSLanguage_CHINESETRADITIONAL` | 2 | 繁体中文 |
| `TSLanguage_ENGLISH` | 3 | 英语 |
| `TSLanguage_GERMAN` | 4 | 德语 |
| `TSLanguage_RUSSIAN` | 5 | 俄语 |
| `TSLanguage_SPANISH` | 6 | 西班牙语 |
| `TSLanguage_PORTUGUESE` | 7 | 葡萄牙语 |
| `TSLanguage_FRENCH` | 8 | 法语 |
| `TSLanguage_JAPANESE` | 9 | 日语 |
| `TSLanguage_ARABIC` | 10 | 阿拉伯语 |
| `TSLanguage_DUTCH` | 11 | 荷兰语 |
| `TSLanguage_ITALIAN` | 12 | 意大利语 |
| `TSLanguage_BENGALI` | 13 | 孟加拉语 |
| `TSLanguage_CROATIAN` | 14 | 克罗地亚语 |
| `TSLanguage_CZECH` | 15 | 捷克语 |
| `TSLanguage_DANISH` | 16 | 丹麦语 |
| `TSLanguage_GREEK` | 17 | 希腊语 |
| `TSLanguage_HEBREW` | 18 | 希伯来语 |
| `TSLanguage_HINDI` | 19 | 印度语 |
| `TSLanguage_HUN` | 20 | 匈牙利语 |
| `TSLanguage_INDONESIAN` | 21 | 印度尼西亚语 |
| `TSLanguage_KOREAN` | 22 | 韩语 |
| `TSLanguage_MALAY` | 23 | 马来语 |
| `TSLanguage_PERSIAN` | 24 | 波斯语 |
| `TSLanguage_POLISH` | 25 | 波兰语 |
| `TSLanguage_RUMANIAN` | 26 | 罗马尼亚语 |
| `TSLanguage_SERB` | 27 | 塞尔维亚语 |
| `TSLanguage_SWEDISH` | 28 | 瑞典语 |
| `TSLanguage_THAI` | 29 | 泰语 |
| `TSLanguage_TURKISH` | 30 | 土耳其语 |
| `TSLanguage_URDU` | 31 | 乌尔都语 |
| `TSLanguage_VIETNAMESE` | 32 | 越南语 |
| `TSLanguage_CATALAN` | 33 | 加泰隆语 |
| `TSLanguage_LATVIAN` | 34 | 拉脱维亚语 |
| `TSLanguage_LITHUANIAN` | 35 | 立陶宛语 |
| `TSLanguage_NORWEGIAN` | 36 | 挪威语 |
| `TSLanguage_SLOVAK` | 37 | 斯洛伐克语 |
| `TSLanguage_SLOVENIAN` | 38 | 斯洛文尼亚语 |
| `TSLanguage_BULGARIAN` | 39 | 保加利亚语 |
| `TSLanguage_UKRAINIAN` | 40 | 乌克兰语 |
| `TSLanguage_FILIPINO` | 41 | 菲律宾语 |
| `TSLanguage_FINNISH` | 42 | 芬兰语 |
| `TSLanguage_SOUTHAFRICAN` | 43 | 南非语 |
| `TSLanguage_ROMANSH` | 44 | 罗曼什语 |
| `TSLanguage_BURMESE` | 45 | 缅甸语 |
| `TSLanguage_CAMBODIAN` | 46 | 柬埔寨语 |
| `TSLanguage_AMHARIC` | 47 | 阿姆哈拉语 |
| `TSLanguage_BELARUSIAN` | 48 | 白俄罗斯语 |
| `TSLanguage_ESTONIAN` | 49 | 爱沙尼亚语 |
| `TSLanguage_SWAHILI` | 50 | 斯瓦希里语 |
| `TSLanguage_ZULU` | 51 | 祖鲁语 |
| `TSLanguage_AZERBAIJANI` | 52 | 阿塞拜疆语 |
| `TSLanguage_ARMENIAN` | 53 | 亚美尼亚语 |
| `TSLanguage_GEORGIAN` | 54 | 格鲁吉亚语 |
| `TSLanguage_LAO` | 55 | 老挝语 |
| `TSLanguage_MONGOLIAN` | 56 | 蒙古语 |
| `TSLanguage_NEPALI` | 57 | 尼泊尔语 |
| `TSLanguage_KAZAKH` | 58 | 哈萨克语 |
| `TSLanguage_GALICIAN` | 59 | 加利西亚语 |
| `TSLanguage_ICELANDIC` | 60 | 冰岛语 |
| `TSLanguage_KANNADA` | 61 | 卡纳达语 |
| `TSLanguage_KYRGYZ` | 62 | 吉尔吉斯语 |
| `TSLanguage_MALAYALAM` | 63 | 马拉雅拉姆语 |
| `TSLanguage_MARATHI` | 64 | 马拉提语 |
| `TSLanguage_TAMIL` | 65 | 泰米尔语 |
| `TSLanguage_MACEDONIAN` | 66 | 马其顿语 |
| `TSLanguage_TELUGU` | 67 | 泰卢固语 |
| `TSLanguage_UZBEK` | 68 | 乌兹别克语 |
| `TSLanguage_BASQUE` | 69 | 巴斯克语 |
| `TSLanguage_BERBER` | 70 | 僧伽罗语 |
| `TSLanguage_ALBANIAN` | 71 | 阿尔巴尼亚语 |
| `TSLanguage_HAUSA` | 72 | 豪萨语 |

## 回调类型

| 回调类型 | 签名 | 说明 |
|---------|------|------|
| `TSLanguageListResultBlock` | `void(^)(NSArray<TSLanguageModel *> * languages, NSError * error)` | 获取语言列表的回调，返回支持的语言模型数组 |
| `TSLanguageResultBlock` | `void(^)(TSLanguageModel * language, NSError * error)` | 获取或设置单个语言的回调，返回语言模型 |
| `TSCompletionBlock` | `void(^)(BOOL success, NSError * error)` | 通用完成回调，返回操作是否成功 |

## 接口方法

### 获取设备支持的语言列表

```objc
- (void)getSupportedLanguages:(nullable TSLanguageListResultBlock)completion;
```

获取设备支持的所有语言列表。

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSLanguageListResultBlock` | 完成回调，返回支持的语言模型数组和错误信息 |

**代码示例：**

```objc
id<TSLanguageInterface> language = [TopStepComKit sharedInstance].language;

[language getSupportedLanguages:^(NSArray<TSLanguageModel *> * _Nonnull languages, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取语言列表失败: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"支持的语言列表数量: %lu", (unsigned long)languages.count);
    for (TSLanguageModel *language in languages) {
        TSLog(@"语言: %@ (代码: %@, 类型: %ld)", language.nativeName, language.code, (long)language.type);
    }
}];
```

### 获取设备当前语言

```objc
- (void)getCurrentLanguage:(nullable TSLanguageResultBlock)completion;
```

获取设备当前设置的语言。

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSLanguageResultBlock` | 完成回调，返回当前语言模型和错误信息 |

**代码示例：**

```objc
id<TSLanguageInterface> language = [TopStepComKit sharedInstance].language;

[language getCurrentLanguage:^(TSLanguageModel * _Nullable language, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取当前语言失败: %@", error.localizedDescription);
        return;
    }
    
    if (language) {
        TSLog(@"当前语言: %@ (代码: %@)", language.nativeName, language.code);
    }
}];
```

### 设置设备语言

```objc
- (void)setLanguage:(TSLanguageModel *)language completion:(TSCompletionBlock)completion;
```

设置设备的显示语言。语言参数必须是 `getSupportedLanguages` 返回的语言列表中的一个，否则会设置失败并返回参数错误。

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `language` | `TSLanguageModel *` | 要设置的语言模型，必须来自 `getSupportedLanguages` 返回的列表 |
| `completion` | `TSCompletionBlock` | 完成回调，返回设置是否成功和错误信息 |

**代码示例：**

```objc
id<TSLanguageInterface> language = [TopStepComKit sharedInstance].language;

// 方式1: 使用语言代码创建语言模型
TSLanguageModel *languageModel = [TSLanguageModel languageWithCode:@"en"];
if (languageModel) {
    [language setLanguage:languageModel completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            TSLog(@"语言设置成功");
        } else {
            TSLog(@"语言设置失败: %@", error.localizedDescription);
        }
    }];
}

// 方式2: 使用语言类型创建语言模型
TSLanguageModel *englishModel = [TSLanguageModel languageWithType:TSLanguage_ENGLISH];
[language setLanguage:englishModel completion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"英语设置成功");
    } else {
        TSLog(@"英语设置失败: %@", error.localizedDescription);
    }
}];
```

### 注册语言变化监听

```objc
- (void)registerLanguageDidChanged:(nullable TSLanguageResultBlock)completion;
```

注册语言变化事件监听。注册后，当设备上报语言变化时会触发回调。

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `completion` | `TSLanguageResultBlock` | 监听回调，当语言变化时触发，返回新的语言模型和错误信息 |

**代码示例：**

```objc
id<TSLanguageInterface> language = [TopStepComKit sharedInstance].language;

[language registerLanguageDidChanged:^(TSLanguageModel * _Nullable language, NSError * _Nullable error) {
    if (error) {
        TSLog(@"语言变化监听出错: %@", error.localizedDescription);
        return;
    }
    
    if (language) {
        TSLog(@"设备语言已变更: %@ (代码: %@)", language.nativeName, language.code);
        // 在这里处理语言变化后的相关业务逻辑
    }
}];
```

### 通过语言代码创建语言模型

```objc
+ (nullable instancetype)languageWithCode:(NSString *)code;
```

根据语言代码创建语言模型实例。

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `code` | `NSString *` | 遵循 ISO 639-1 标准的语言代码（如 "en" 表示英语，"zh" 表示中文） |

**返回值：** `TSLanguageModel *` —— 语言模型实例，无效的语言代码返回 `nil`

**代码示例：**

```objc
// 创建英语语言模型
TSLanguageModel *englishModel = [TSLanguageModel languageWithCode:@"en"];
if (englishModel) {
    TSLog(@"英语模型创建成功: %@", englishModel.nativeName);
} else {
    TSLog(@"无效的语言代码");
}

// 创建中文语言模型
TSLanguageModel *chineseModel = [TSLanguageModel languageWithCode:@"zh"];
if (chineseModel) {
    TSLog(@"中文模型创建成功: %@", chineseModel.nativeName);
}
```

### 通过语言类型创建语言模型

```objc
+ (nullable instancetype)languageWithType:(TSLanguageType)type;
```

根据语言类型枚举值创建语言模型实例。

**参数：**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `type` | `TSLanguageType` | 语言类型枚举值（如 `TSLanguage_ENGLISH` 表示英语） |

**返回值：** `TSLanguageModel *` —— 语言模型实例，无效或不支持的语言类型返回 `nil`

**代码示例：**

```objc
// 创建英语语言模型
TSLanguageModel *englishModel = [TSLanguageModel languageWithType:TSLanguage_ENGLISH];
if (englishModel) {
    TSLog(@"创建成功 - 类型: %ld, 代码: %@, 本地名称: %@", 
          (long)englishModel.type, englishModel.code, englishModel.nativeName);
}

// 创建日语语言模型
TSLanguageModel *japaneseModel = [TSLanguageModel languageWithType:TSLanguage_JAPANESE];
if (japaneseModel) {
    TSLog(@"日语模型: %@（中文名: %@）", japaneseModel.nativeName, japaneseModel.chineseName);
}
```

## 注意事项

1. **语言代码有效性**：设置语言时，传入的 `TSLanguageModel` 必须是 `getSupportedLanguages` 返回列表中的一个，否则会返回参数错误。

2. **异步操作**：所有接口方法都是异步操作，必须通过回调获取结果。不要在回调中进行长时间阻塞操作，以免影响 UI 响应。

3. **错误处理**：始终检查回调中的 `error` 参数。当 `error` 不为 `nil` 时，表示操作失败，此时其他返回值可能无效。

4. **语言模型创建**：使用 `languageWithCode:` 或 `languageWithType:` 创建语言模型时，如果返回值为 `nil`，说明语言代码或类型无效或不被支持。

5. **监听注册**：`registerLanguageDidChanged:` 应在应用启动时调用一次，之后会持续监听设备的语言变化。该回调会在语言变化时被多次触发。

6. **线程安全**：回调可能在后台线程执行，如果需要更新 UI，请切换到主线程操作。

7. **语言代码标准**：语言代码遵循 ISO 639-1 标准，大多数使用小写两字母代码（如 "en"、"zh" 等）。
