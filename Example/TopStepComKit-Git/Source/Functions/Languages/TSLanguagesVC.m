//
//  TSLanguagesVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSLanguagesVC.h"

@interface TSLanguagesVC ()

@end

@implementation TSLanguagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"语言设置";
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"获取当前语言"],
        [TSValueModel valueWithName:@"获取所支持的语言"],
        [TSValueModel valueWithName:@"设置语言"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self getCurrentLanguage];
    } else if (indexPath.row == 1) {
        [self getSupportLanguages];
    } else {
        [self setCurrenLanguage];
    }
}

- (void)getCurrentLanguage {
    TSLog(@"开始获取当前语言");
    
    [[[TopStepComKit sharedInstance] language] getCurrentLanguageWithCompletion:^(TSLanguageModel * _Nullable language, NSError * _Nullable error) {
        if (language) {
            TSLog(@"获取当前语言成功:\n"
                  "- 语言代码: %@\n"
                  "- 本地名称: %@\n"
                  "- 中文名称: %@",
                  language.languageCode,
                  language.nativeName,
                  language.chineseName);
            
            [TSToast showText:[NSString stringWithFormat:@"当前语言: %@", language.chineseName]
                     onView:self.view
            dismissAfterDelay:1.0f];
        } else {
            NSString *errorMsg = error.localizedDescription ?: @"未知错误";
            TSLog(@"获取当前语言失败: %@", errorMsg);
            
            [TSToast showText:[NSString stringWithFormat:@"获取当前语言失败: %@", errorMsg]
                     onView:self.view
            dismissAfterDelay:1.0f];
        }
    }];
}

- (void)getSupportLanguages {
    TSLog(@"开始获取支持的语言列表");
    
    [[[TopStepComKit sharedInstance] language] getSupportedLanguagesWithCompletion:^(NSArray<TSLanguageModel *> * _Nonnull languages, NSError * _Nullable error) {
        if (languages.count > 0) {
            TSLog(@"获取支持的语言列表成功，共%lu种语言:", (unsigned long)languages.count);
            
            // 打印每种语言的详细信息
            [languages enumerateObjectsUsingBlock:^(TSLanguageModel * _Nonnull language, NSUInteger idx, BOOL * _Nonnull stop) {
                TSLog(@"%lu. %@(%@) - %@",
                      (unsigned long)(idx + 1),
                      language.nativeName,
                      language.chineseName,
                      language.languageCode);
            }];
            
            [TSToast showText:[NSString stringWithFormat:@"支持%lu种语言", (unsigned long)languages.count]
                     onView:self.view
            dismissAfterDelay:1.0f];
        } else {
            NSString *errorMsg = error.localizedDescription ?: @"未知错误";
            TSLog(@"获取支持的语言列表失败: %@", errorMsg);
            
            [TSToast showText:[NSString stringWithFormat:@"获取语言列表失败: %@", errorMsg]
                     onView:self.view
            dismissAfterDelay:1.0f];
        }
    }];
}

- (TSLanguageModel *)randLanguage {
    // 创建支持的语言数组
    NSArray *allLanguages = @[
        [TSLanguageModel languageWithType:TSLanguage_ENGLISH],
        [TSLanguageModel languageWithType:TSLanguage_CHINESESIMPLIFIED],
        [TSLanguageModel languageWithType:TSLanguage_SOUTHAFRICAN],
        [TSLanguageModel languageWithType:TSLanguage_PORTUGUESE],
        [TSLanguageModel languageWithType:TSLanguage_ARABIC],
    ];
    
    // 生成随机索引
    NSInteger random = (NSInteger)arc4random_uniform(5);
    TSLanguageModel *selectedLanguage = allLanguages[random];
    
    TSLog(@"随机选择语言: %@(%@)", selectedLanguage.nativeName, selectedLanguage.chineseName);
    return selectedLanguage;
}

- (void)setCurrenLanguage {
    TSLanguageModel *language = [self randLanguage];
    TSLog(@"开始设置语言: %@", language.chineseName);
    
    [[[TopStepComKit sharedInstance] language] setLanguage:language completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            TSLog(@"设置语言成功: %@", language.chineseName);
            [TSToast showText:[NSString stringWithFormat:@"设置语言成功: %@", language.chineseName]
                     onView:self.view
            dismissAfterDelay:1.0f];
        } else {
            NSString *errorMsg = error.localizedDescription ?: @"未知错误";
            TSLog(@"设置语言失败: %@", errorMsg);
            
            [TSToast showText:[NSString stringWithFormat:@"设置语言失败: %@", errorMsg]
                     onView:self.view
            dismissAfterDelay:1.0f];
        }
    }];
}

@end
