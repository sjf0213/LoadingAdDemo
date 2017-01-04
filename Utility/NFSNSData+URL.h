//
//  NFSNSData+URL.h
//  NewFusionSDK
//
//  Created by xiong qi on 15/11/30.
//  Copyright © 2015年 xiongqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (URL)
- (NSString *)base64EncodedString;
- (NSString *)md5String;
- (NSString *)hexString;
@end