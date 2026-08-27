//
//  StarburstFileAsrModel.h
//  StarburstSdk
//
//  Created by incar on 2024/9/27.
//

#import <Foundation/Foundation.h>

/// 该段说话人
@interface StarburstFileAsrAdditions : NSObject
@property (nonatomic, strong) NSString *speaker;/// 该段说话人编号
@end

/// 识别片段
@interface StarburstFileAsrPieces : NSObject
@property (nonatomic, strong) NSString *text;/// 片段识别的内筒
@property (nonatomic, assign) NSInteger start_time;///片段对应文件进度，单位毫秒
@property (nonatomic, assign) NSInteger end_time;///  片段对应文件进度，单位毫秒
@property (nonatomic, strong) StarburstFileAsrAdditions *additions;///该段说话人
@end

/// 文件识别结果模型
@interface StarburstFileAsrModel : NSObject
@property (nonatomic, assign) NSInteger code;/// 状态码
@property (nonatomic, strong) NSString *msg;/// 提示语
@property (nonatomic, strong) NSString *requestId;/// 请求id
@property (nonatomic, strong) NSString *taskId;/// 任务id
@property (nonatomic, strong) NSString *text;/// 语⾳识别内容
@property (nonatomic, strong) NSString *summary;/// 识别摘要内容
@property (nonatomic, strong) NSString *transText;///识别后翻译结果
@property (nonatomic, strong) NSArray<StarburstFileAsrPieces *> *pieces;///识别片段

+ (StarburstFileAsrModel *)modelWith:(NSDictionary *)dict;
@end

