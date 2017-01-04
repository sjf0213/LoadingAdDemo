//
//  NFSString+URL.h
//  NewFusionSDK
//
//  Created by xiong qi on 15/11/30.
//  Copyright © 2015年 xiongqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URL)
- (NSString *)stringByAppendingQuery:(NSDictionary *)query key:(NSString *)key;

- (NSString *)stringByAppendingQuery:(NSDictionary *)query postdata:(NSData *)postdata key:(NSString *)key;

- (NSDictionary *)queriesWithQueries:(NSDictionary *)queries key:(NSString *)key;

- (NSString *)base64EncodedString;
- (NSString *)md5String;
- (NSString *)urlEncodedString;
- (NSString *)urlDecodingString;

- (NSMutableDictionary*)parserQueryText;

- (NSString*)stringByRemovingEncryptQuery;
@end
