//
//  LoadingAdModel.m
//  Lahong
//
//  Created by 宋炬峰 on 2016/12/19.
//  Copyright © 2016年 appfactory. All rights reserved.
//

#import "LoadingAdModel.h"

@interface LoadingAdModel()

@property (nonatomic, copy, readwrite) NSString* ID;
@property (nonatomic, assign, readwrite) NSTimeInterval showTime;
@property (nonatomic, assign, readwrite) LoadingAdJumpType jumpType;
@property (nonatomic, copy, readwrite) NSString *link;
@property (nonatomic, copy, readwrite) NSString *imgURL;
@property (nonatomic, copy, readwrite) NSString *imgURL_4s;

@end

@implementation LoadingAdModel

-(instancetype)initWithDic:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString* tempStr = dic[@"id"];
            if ([tempStr isKindOfClass:[NSString class]] ||
                [tempStr isKindOfClass:[NSNumber class]]) {
                _ID = [NSString stringWithFormat:@"%zd", tempStr.integerValue];
            }
            
            tempStr = dic[@"jump"];
            if ([tempStr isKindOfClass:[NSString class]] ||
                [tempStr isKindOfClass:[NSNumber class]]) {
                NSInteger n = tempStr.integerValue;
                switch (n) {
                    case 1:
                    {
                        _jumpType = LoadingAdJump_InnerWeb;
                    }
                        break;
                    case 2:
                    {
                        _jumpType = LoadingAdJump_Safari;
                    }
                        break;
                    default:
                    {
                        _jumpType = LoadingAdJump_InnerWeb;
                    }
                        break;
                }
            }
            tempStr = dic[@"delay"];
            if ([tempStr isKindOfClass:[NSString class]] ||
                [tempStr isKindOfClass:[NSNumber class]]) {
                _showTime = tempStr.doubleValue;
            }
            _link = dic[@"clink"];
            _imgURL = dic[@"img"];
            _imgURL_4s = dic[@"img_4s"];
        }
    }
    return self;
}
@end
