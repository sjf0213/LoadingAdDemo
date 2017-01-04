//
//  LoadingAdModel.h
//  Lahong
//
//  Created by 宋炬峰 on 2016/12/19.
//  Copyright © 2016年 appfactory. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LoadingAdJumpType){
    LoadingAdJump_Unknown = 0,
    LoadingAdJump_InnerWeb,
    LoadingAdJump_Safari,
};

@interface LoadingAdModel : NSObject

@property (nonatomic, copy, readonly) NSString* ID;
@property (nonatomic, assign, readonly) NSTimeInterval showTime;
@property (nonatomic, assign, readonly) LoadingAdJumpType jumpType;
@property (nonatomic, copy, readonly) NSString *link;
@property (nonatomic, copy, readonly) NSString *imgURL;
@property (nonatomic, copy, readonly) NSString *imgURL_4s;

-(instancetype)initWithDic:(NSDictionary*)dic;

@end
