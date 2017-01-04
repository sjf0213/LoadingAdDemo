//
//  NFSNSData+URL.m
//  NewFusionSDK
//
//  Created by xiong qi on 15/11/30.
//  Copyright © 2015年 xiongqi. All rights reserved.
//

#import "NFSNSData+URL.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSData (URL)
- (NSString *)base64EncodedString {
    NSString* encodeResult = [self base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodeResult;
}

- (NSString *)md5String {
    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (unsigned int)self.length, buffer);
    
    return [[NSData dataWithBytesNoCopy:buffer length:CC_MD5_DIGEST_LENGTH freeWhenDone:NO] hexString];
}

- (NSString *)hexString {
    NSMutableString * description = [NSMutableString stringWithString:[self description]];
    [description replaceOccurrencesOfString:@"[^0-9a-fA-F]+" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, description.length)];
    
    return [description lowercaseString];
}
@end

