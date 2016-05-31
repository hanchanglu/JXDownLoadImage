//
//  JXModel.h
//  JXDownLoadImage
//
//  Created by yuezuo on 16/5/30.
//  Copyright © 2016年 yuezuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXModel : NSObject
/** 图片 */
@property (nonatomic,strong) NSString * icon;
/** 名字 */
@property (nonatomic,strong) NSString * name;
/** 下载量 */
@property (nonatomic,strong) NSString * download;

+ (instancetype)modelWithDict:(NSDictionary *)dict;
@end
