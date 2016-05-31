
//
//  JXModel.m
//  JXDownLoadImage
//
//  Created by yuezuo on 16/5/30.
//  Copyright © 2016年 yuezuo. All rights reserved.
//

#import "JXModel.h"

@implementation JXModel
+ (instancetype)modelWithDict:(NSDictionary *)dict {
    JXModel * model = [[self alloc] init];
    
    [model setValuesForKeysWithDictionary:dict];
    
    return model;
}
@end
