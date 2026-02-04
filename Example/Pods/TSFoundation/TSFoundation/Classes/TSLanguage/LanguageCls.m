//
//  LanguageCls.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/12/24.
//

#import "LanguageCls.h"
#import <DFUnits/DFUnits.h>
#import "JLPhoneUISetting.h"

#define LocalLanguage  @"LocalLanguage"

@interface LanguageCls()

@property(nonatomic,strong)NSHashTable         *delegates;
@property(nonatomic,strong)NSLock              *delegateLock;
@property(nonatomic,copy)NSArray *supportLans;
@end

@implementation LanguageCls


- (NSArray *)supportLans {
    if (!_supportLans) {
        _supportLans = @[@"en", @"zh-Hans", @"zh-Hant", @"de", @"ja", @"ko", @"es", @"fr", @"ar", @"cs", @"el", @"fa", @"it", @"nl", @"pl", @"pt", @"ru", @"fi", @"sv", @"th", @"hu", @"sk", @"sq", @"hr", @"uk", @"tr", @"hi", @"da", @"vi", @"he", @"id", @"ms", @"nb"];
    }
    return _supportLans;
}

+(instancetype)share{
    static LanguageCls *me;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        me = [[LanguageCls alloc] init];
    });
    
    
    return me;
}

-(NSLock *)delegateLock{
    if (_delegateLock == nil) {
        _delegateLock = [NSLock new];
    }
    return _delegateLock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

-(void)add:(id<LanguagePtl>)objc{
    [self.delegateLock lock];
    if (![self.delegates containsObject:objc]) {
        [self.delegates addObject:objc];
    }
    [self.delegateLock unlock];
}

-(void)remove:(id<LanguagePtl>)objc{
    [self.delegateLock lock];
    if ([self.delegates containsObject:objc]) {
        [self.delegates removeObject:objc];
    }
    [self.delegateLock unlock];
}

-(void)setLanguage:(NSString *)lgg{
    for (NSObject<LanguagePtl> *objc in self.delegates) {
        if ([objc respondsToSelector:@selector(languageChange)]) {
            [objc languageChange];
        }
    }
}

+(NSString *)checkLanguage {
    NSString *objc = [[NSUserDefaults standardUserDefaults] valueForKey:LocalLanguage];
    if (objc && ![objc isEqualToString:@""]) {
        return objc;
    }else{
        NSString *currentLang = [[NSBundle mainBundle] preferredLocalizations].firstObject;
//        NSLog(@"currentLang is %@",currentLang);
        return  currentLang;
//        return [DFUITools systemLanguage];
    }
}

+(void)setLangague:(NSString *)lan{
    [[NSUserDefaults standardUserDefaults] setValue:lan forKey:LocalLanguage];
    if ([lan isEqual:@""]) {
//        [DFUITools languageSet:[DFUITools systemLanguage]];
//        [[self share] setLanguage:[DFUITools systemLanguage]];
    }else{
//        [DFUITools languageSet:lan];
        [[self share] setLanguage:lan];
    }
}

+(NSString *)localizableTxt:(NSString *)key{
//    NSString *str = [DFUITools languageText:key Table:@"Localizable/Localizable"];
    /*--- 检测当前语言 ---*/
    __block NSString *path = @"";
    NSString *lan = kJL_GET;
    if ([lan hasPrefix:@"zh-Hant"]) {
        path = [[NSBundle mainBundle] pathForResource:@"zh-Hant" ofType:@"lproj"];
    }else if ([lan hasPrefix:@"zh-Hans"]){
        path = [[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
    }else if ([lan hasPrefix:@"pt-PT"]){
        path = [[NSBundle mainBundle] pathForResource:@"pt-PT" ofType:@"lproj"];
    }else{
        NSArray *comps = [lan componentsSeparatedByString:@"-"];
        NSString *lanName = comps.firstObject;
        path = [[NSBundle mainBundle] pathForResource:lanName ofType:@"lproj"];
    }
    if (path.length == 0) {
        path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
    }
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:nil table:@"Localizable"];
}



+(BOOL)isChinese{
    if ([kJL_GET hasPrefix:@"zh"]){
        return YES;
    }
    return NO;
}

+(BOOL)isTraditionalChinese{
    
    if ([kJL_GET hasPrefix:@"zh-hant"]){
        return YES;
    }
    return NO;
}

@end
