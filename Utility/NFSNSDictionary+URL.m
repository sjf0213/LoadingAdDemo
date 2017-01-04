//
//  NFSDictionary.m
//  NewFusionSDK
//
//  Created by xiong qi on 15/11/30.
//  Copyright © 2015年 xiongqi. All rights reserved.
//

#import "NFSNSDictionary+URL.h"
#import "NFSNSString+URL.h"

@implementation NSDictionary (URL)
- (NSString *)urlEncodedKeyValueString {
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in self) {
        
        NSObject *value = [self valueForKey:key];
        if([value isKindOfClass:[NSString class]])
            [string appendFormat:@"%@=%@&", key.urlEncodedString, ((NSString*)value).urlEncodedString];
        else
            [string appendFormat:@"%@=%@&", key.urlEncodedString, value];
    }
    
    if([string length] > 0)
        [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
    
    return string;
}

@end