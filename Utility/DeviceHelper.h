//
//  DeviceHelper.h
//  FafaBang
//
//  Created by xiong qi on 15/12/14.
//  Copyright © 2015年 xiongqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceHelper : NSObject

@property (nonatomic,strong,readonly)NSString * deviceModel;
@property (nonatomic,strong,readonly)NSString * systemVersion;
@property (nonatomic,strong,readonly)NSString * idfaStr;
@property (nonatomic,strong,readonly)NSString * appver;
@property (nonatomic,strong,readonly)NSString * macaddr;
@property (nonatomic,strong,readonly)NSString * cliendTypeID;
@property (nonatomic,strong,readonly)NSString * appID;// 梦工厂内部的appID
@property (nonatomic,assign,readonly)BOOL jailbreakflag;
+ (DeviceHelper*)shareInstance;
@end
