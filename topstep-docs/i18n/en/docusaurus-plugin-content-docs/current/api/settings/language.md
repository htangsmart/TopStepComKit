---
sidebar_position: 3
title: Language
---

# TSLanguage Module

The TSLanguage module provides device language management capabilities, enabling applications to retrieve supported languages, query the current device language, change the device language, and monitor language change events. This module supports over 70 languages and integrates seamlessly with the TopStepComKit framework.

## Prerequisites

- TopStepComKit SDK version 1.0 or higher
- Connected device with language management capability
- Valid device connection through TopStepComKit
- Proper initialization of the TopStepComKit framework

## Data Models

### TSLanguageModel

Language information model representing a supported language on the device.

| Property | Type | Description |
|----------|------|-------------|
| `type` | `TSLanguageType` | Language type enum value (e.g., TSLanguage_ENGLISH for English, TSLanguage_CHINESESIMPLIFIED for Chinese) |
| `code` | `NSString *` | Language code following ISO 639-1 standard (e.g., "en" for English, "zh" for Chinese) |
| `nativeName` | `NSString *` | Name of the language in its own language (e.g., "English" for English, "中文" for Chinese) |
| `chineseName` | `NSString *` | Name of the language in Chinese (e.g., "英语" for English, "中文" for Chinese) |

### TSLanguageConfig

Language configuration management class responsible for managing all language configurations.

| Property | Type | Description |
|----------|------|-------------|
| `languageConfigMap` (class method) | `NSDictionary *` | Dictionary containing all language configurations; key is language type, value is configuration dictionary |

## Enumerations

### TSLanguageType

Supported language types in the system, used for language switching and localization.

| Value | Code | English Name | Chinese Name |
|-------|------|--------------|--------------|
| `TSLanguage_UNKNOW` | 0 | Unknown | 未设置 |
| `TSLanguage_CHINESESIMPLIFIED` | 1 | Simplified Chinese | 简体中文 |
| `TSLanguage_CHINESETRADITIONAL` | 2 | Traditional Chinese | 繁体中文 |
| `TSLanguage_ENGLISH` | 3 | English | 英语 |
| `TSLanguage_GERMAN` | 4 | German | 德语 |
| `TSLanguage_RUSSIAN` | 5 | Russian | 俄语 |
| `TSLanguage_SPANISH` | 6 | Spanish | 西班牙语 |
| `TSLanguage_PORTUGUESE` | 7 | Portuguese | 葡萄牙语 |
| `TSLanguage_FRENCH` | 8 | French | 法语 |
| `TSLanguage_JAPANESE` | 9 | Japanese | 日语 |
| `TSLanguage_ARABIC` | 10 | Arabic | 阿拉伯语 |
| `TSLanguage_DUTCH` | 11 | Dutch | 荷兰语 |
| `TSLanguage_ITALIAN` | 12 | Italian | 意大利语 |
| `TSLanguage_BENGALI` | 13 | Bengali | 孟加拉语 |
| `TSLanguage_CROATIAN` | 14 | Croatian | 克罗地亚语 |
| `TSLanguage_CZECH` | 15 | Czech | 捷克语 |
| `TSLanguage_DANISH` | 16 | Danish | 丹麦语 |
| `TSLanguage_GREEK` | 17 | Greek | 希腊语 |
| `TSLanguage_HEBREW` | 18 | Hebrew | 希伯来语 |
| `TSLanguage_HINDI` | 19 | Hindi | 印度语 |
| `TSLanguage_HUN` | 20 | Hungarian | 匈牙利语 |
| `TSLanguage_INDONESIAN` | 21 | Indonesian | 印度尼西亚语 |
| `TSLanguage_KOREAN` | 22 | Korean | 韩语 |
| `TSLanguage_MALAY` | 23 | Malay | 马来语 |
| `TSLanguage_PERSIAN` | 24 | Persian | 波斯语 |
| `TSLanguage_POLISH` | 25 | Polish | 波兰语 |
| `TSLanguage_RUMANIAN` | 26 | Romanian | 罗马尼亚语 |
| `TSLanguage_SERB` | 27 | Serbian | 塞尔维亚语 |
| `TSLanguage_SWEDISH` | 28 | Swedish | 瑞典语 |
| `TSLanguage_THAI` | 29 | Thai | 泰语 |
| `TSLanguage_TURKISH` | 30 | Turkish | 土耳其语 |
| `TSLanguage_URDU` | 31 | Urdu | 乌尔都语 |
| `TSLanguage_VIETNAMESE` | 32 | Vietnamese | 越南语 |
| `TSLanguage_CATALAN` | 33 | Catalan | 加泰隆语 |
| `TSLanguage_LATVIAN` | 34 | Latvian | 拉脱维亚语 |
| `TSLanguage_LITHUANIAN` | 35 | Lithuanian | 立陶宛语 |
| `TSLanguage_NORWEGIAN` | 36 | Norwegian | 挪威语 |
| `TSLanguage_SLOVAK` | 37 | Slovak | 斯洛伐克语 |
| `TSLanguage_SLOVENIAN` | 38 | Slovenian | 斯洛文尼亚语 |
| `TSLanguage_BULGARIAN` | 39 | Bulgarian | 保加利亚语 |
| `TSLanguage_UKRAINIAN` | 40 | Ukrainian | 乌克兰语 |
| `TSLanguage_FILIPINO` | 41 | Filipino | 菲律宾语 |
| `TSLanguage_FINNISH` | 42 | Finnish | 芬兰语 |
| `TSLanguage_SOUTHAFRICAN` | 43 | South African | 南非语 |
| `TSLanguage_ROMANSH` | 44 | Romansh | 罗曼什语 |
| `TSLanguage_BURMESE` | 45 | Burmese | 缅甸语 |
| `TSLanguage_CAMBODIAN` | 46 | Cambodian | 柬埔寨语 |
| `TSLanguage_AMHARIC` | 47 | Amharic | 阿姆哈拉语 |
| `TSLanguage_BELARUSIAN` | 48 | Belarusian | 白俄罗斯语 |
| `TSLanguage_ESTONIAN` | 49 | Estonian | 爱沙尼亚语 |
| `TSLanguage_SWAHILI` | 50 | Swahili | 斯瓦希里语 |
| `TSLanguage_ZULU` | 51 | Zulu | 祖鲁语 |
| `TSLanguage_AZERBAIJANI` | 52 | Azerbaijani | 阿塞拜疆语 |
| `TSLanguage_ARMENIAN` | 53 | Armenian | 亚美尼亚语 |
| `TSLanguage_GEORGIAN` | 54 | Georgian | 格鲁吉亚语 |
| `TSLanguage_LAO` | 55 | Lao | 老挝语 |
| `TSLanguage_MONGOLIAN` | 56 | Mongolian | 蒙古语 |
| `TSLanguage_NEPALI` | 57 | Nepali | 尼泊尔语 |
| `TSLanguage_KAZAKH` | 58 | Kazakh | 哈萨克语 |
| `TSLanguage_GALICIAN` | 59 | Galician | 加利西亚语 |
| `TSLanguage_ICELANDIC` | 60 | Icelandic | 冰岛语 |
| `TSLanguage_KANNADA` | 61 | Kannada | 卡纳达语 |
| `TSLanguage_KYRGYZ` | 62 | Kyrgyz | 吉尔吉斯语 |
| `TSLanguage_MALAYALAM` | 63 | Malayalam | 马拉雅拉姆语 |
| `TSLanguage_MARATHI` | 64 | Marathi | 马拉提语 |
| `TSLanguage_TAMIL` | 65 | Tamil | 泰米尔语 |
| `TSLanguage_MACEDONIAN` | 66 | Macedonian | 马其顿语 |
| `TSLanguage_TELUGU` | 67 | Telugu | 泰卢固语 |
| `TSLanguage_UZBEK` | 68 | Uzbek | 乌兹别克语 |
| `TSLanguage_BASQUE` | 69 | Basque | 巴斯克语 |
| `TSLanguage_BERBER` | 70 | Sinhala | 僧伽罗语 |
| `TSLanguage_ALBANIAN` | 71 | Albanian | 阿尔巴尼亚语 |
| `TSLanguage_HAUSA` | 72 | Hausa | 豪萨语 |

## Callback Types

### TSLanguageListResultBlock

Callback for retrieving the list of supported languages.

```objc
typedef void(^TSLanguageListResultBlock)(NSArray<TSLanguageModel *> * _Nonnull languages, NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `languages` | `NSArray<TSLanguageModel *> *` | Array of supported language models; empty array if retrieval fails |
| `error` | `NSError *` | Error information; nil if successful |

### TSLanguageResultBlock

Callback for retrieving current language information.

```objc
typedef void(^TSLanguageResultBlock)(TSLanguageModel * _Nullable language, NSError * _Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `language` | `TSLanguageModel *` | Current language model; nil if retrieval fails |
| `error` | `NSError *` | Error information; nil if successful |

## API Reference

### Retrieve supported language list

Fetch all languages supported by the device.

```objc
- (void)getSupportedLanguages:(nullable TSLanguageListResultBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSLanguageListResultBlock` | Completion callback with supported languages array and error information |

**Code Example:**

```objc
id<TSLanguageInterface> language = [TopStepComKit sharedInstance].language;

[language getSupportedLanguages:^(NSArray<TSLanguageModel *> * _Nonnull languages, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get supported languages: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Supported languages count: %lu", (unsigned long)languages.count);
    for (TSLanguageModel *language in languages) {
        TSLog(@"Language: %@ (%@) - Code: %@", language.nativeName, language.chineseName, language.code);
    }
}];
```

### Get current device language

Query the currently set language on the device.

```objc
- (void)getCurrentLanguage:(nullable TSLanguageResultBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSLanguageResultBlock` | Completion callback with current language model and error information |

**Code Example:**

```objc
id<TSLanguageInterface> language = [TopStepComKit sharedInstance].language;

[language getCurrentLanguage:^(TSLanguageModel * _Nullable language, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to get current language: %@", error.localizedDescription);
        return;
    }
    
    if (language) {
        TSLog(@"Current language: %@ (%@)", language.nativeName, language.chineseName);
        TSLog(@"Language code: %@", language.code);
        TSLog(@"Language type: %ld", (long)language.type);
    }
}];
```

### Set device language

Change the device display language.

```objc
- (void)setLanguage:(TSLanguageModel *)language completion:(TSCompletionBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `language` | `TSLanguageModel *` | Language model to set; must be from the list returned by getSupportedLanguages |
| `completion` | `TSCompletionBlock` | Completion callback with operation result and error information |

**Code Example:**

```objc
id<TSLanguageInterface> language = [TopStepComKit sharedInstance].language;

// First, get the supported languages
[language getSupportedLanguages:^(NSArray<TSLanguageModel *> * _Nonnull languages, NSError * _Nullable error) {
    if (error || languages.count == 0) {
        TSLog(@"Failed to get supported languages");
        return;
    }
    
    // Find English language
    TSLanguageModel *englishLanguage = nil;
    for (TSLanguageModel *lang in languages) {
        if ([lang.code isEqualToString:@"en"]) {
            englishLanguage = lang;
            break;
        }
    }
    
    if (englishLanguage) {
        // Set device language to English
        [language setLanguage:englishLanguage completion:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                TSLog(@"Failed to set language: %@", error.localizedDescription);
                return;
            }
            
            if (success) {
                TSLog(@"Language set successfully to: %@", englishLanguage.nativeName);
            } else {
                TSLog(@"Failed to set language");
            }
        }];
    }
}];
```

### Register language change notification

Monitor device language changes and receive notifications when the language is modified.

```objc
- (void)registerLanguageDidChanged:(nullable TSLanguageResultBlock)completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSLanguageResultBlock` | Callback invoked whenever the device language changes |

**Code Example:**

```objc
id<TSLanguageInterface> language = [TopStepComKit sharedInstance].language;

// Register for language change notifications
[language registerLanguageDidChanged:^(TSLanguageModel * _Nullable language, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Language change notification error: %@", error.localizedDescription);
        return;
    }
    
    if (language) {
        TSLog(@"Device language changed to: %@ (%@)", language.nativeName, language.chineseName);
        TSLog(@"New language code: %@", language.code);
    }
}];
```

### Create language model with language code

Create a TSLanguageModel instance using an ISO 639-1 language code.

```objc
+ (nullable instancetype)languageWithCode:(NSString *)code;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | `NSString *` | ISO 639-1 language code (e.g., "en" for English, "zh" for Chinese) |

**Return:** `TSLanguageModel *` — Language model instance, or nil if the language code is invalid

**Code Example:**

```objc
// Create language model for English
TSLanguageModel *englishLanguage = [TSLanguageModel languageWithCode:@"en"];
if (englishLanguage) {
    TSLog(@"English language: %@ - %@", englishLanguage.nativeName, englishLanguage.chineseName);
} else {
    TSLog(@"Invalid language code");
}
```

### Create language model with language type

Create a TSLanguageModel instance using a TSLanguageType enum value.

```objc
+ (nullable instancetype)languageWithType:(TSLanguageType)type;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | `TSLanguageType` | Language type enum value (e.g., TSLanguage_ENGLISH, TSLanguage_CHINESESIMPLIFIED) |

**Return:** `TSLanguageModel *` — Language model instance, or nil if the language type is invalid or not supported

**Code Example:**

```objc
// Create language model for Simplified Chinese
TSLanguageModel *chineseLanguage = [TSLanguageModel languageWithType:TSLanguage_CHINESESIMPLIFIED];
if (chineseLanguage) {
    TSLog(@"Chinese language: %@ - %@", chineseLanguage.nativeName, chineseLanguage.chineseName);
} else {
    TSLog(@"Language type not supported");
}
```

### Get language configuration dictionary

Retrieve the complete language configuration mapping.

```objc
+ (NSDictionary *)languageConfigMap;
```

**Return:** `NSDictionary *` — Dictionary containing all language configurations; key is language type, value is configuration dictionary

**Code Example:**

```objc
NSDictionary *configMap = [TSLanguageConfig languageConfigMap];
TSLog(@"Language configuration count: %lu", (unsigned long)configMap.count);

for (NSNumber *typeKey in configMap) {
    NSDictionary *config = configMap[typeKey];
    TSLog(@"Type: %@, Config: %@", typeKey, config);
}
```

### Get language type from language code

Convert an ISO 639-1 language code to its corresponding TSLanguageType enum value.

```objc
+ (TSLanguageType)languageTypeWithCode:(NSString *)code;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | `NSString *` | ISO 639-1 language code (e.g., "en", "zh") |

**Return:** `TSLanguageType` — Corresponding language type enum value; TSLanguage_UNKNOW if code is invalid

**Code Example:**

```objc
TSLanguageType languageType = [TSLanguageConfig languageTypeWithCode:@"en"];
if (languageType != TSLanguage_UNKNOW) {
    TSLog(@"Language type for 'en': %ld", (long)languageType);
} else {
    TSLog(@"Unknown language code");
}
```

## Important Notes

1. **Language Code Format:** Language codes follow the ISO 639-1 standard (two-letter codes such as "en", "zh", "fr"). Ensure you use the correct format when setting or querying languages.

2. **Valid Language Requirement:** The language model passed to `setLanguage:completion:` must be one returned by `getSupportedLanguages:`. Attempting to set an unsupported language will result in a parameter error.

3. **Callback Execution:** All completion callbacks are executed asynchronously. Do not assume they execute immediately; use the error parameter to determine operation success.

4. **Nil Handling:** When creating language models with factory methods (`languageWithCode:` or `languageWithType:`), always check for nil returns, as invalid inputs will return nil instead of raising exceptions.

5. **Language Change Notifications:** Register for language change notifications early in your application lifecycle to capture all language changes. The callback will be invoked whenever the device reports a language modification.

6. **Error Information:** Check the error parameter in callbacks for detailed failure reasons. Error codes and descriptions follow the TopStepComKit error handling conventions.

7. **Network Requirements:** Language operations communicate with the connected device. Ensure the device is connected and responsive before performing language operations.

8. **Language Persistence:** Language settings are persisted on the device. After successfully setting a language, it remains active even if the device is disconnected and reconnected.

9. **Model Properties:** The TSLanguageModel provides three different representations of language information (type, code, nativeName, chineseName) for flexible usage in different application contexts.

10. **Configuration Map Usage:** The `languageConfigMap` provides low-level access to language configurations and is primarily for advanced use cases; prefer high-level API methods for typical operations.