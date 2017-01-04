//
//  UrlReplaceHelp.m
//  Weather
//
//  Created by xiongqi on 16/9/2.
//  Copyright © 2016年 Wxl.Haiyue. All rights reserved.
//

#import "UrlReplaceHelp.h"
#import "DeviceHelper.h"

@implementation UrlReplaceHelp

+(UrlReplaceHelp*)sharedInstance{
    static UrlReplaceHelp * s_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_sharedManager = [UrlReplaceHelp new];
    });
    
    return s_sharedManager;
}

- (id)init{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}


- (NSString *)replaceurl:(NSString *)urlString
{
    if (urlString != nil) {
        
        NSString * idfa = [DeviceHelper shareInstance].idfaStr;
        NSString * device = [DeviceHelper shareInstance].deviceModel;
        
        
        urlString = [urlString stringByReplacingOccurrencesOfString:@"{idfa}" withString:idfa==nil?@"":idfa];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"{aid}" withString:[DeviceHelper shareInstance].appID];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"{device}" withString:device==nil?@"":device];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"{iosver}" withString:[DeviceHelper shareInstance].systemVersion];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"{appver}" withString:[DeviceHelper shareInstance].appver];
        
    }
    
    return urlString;
}

@end
