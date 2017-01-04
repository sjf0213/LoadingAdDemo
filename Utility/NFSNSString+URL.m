//
//  NFSString+URL.m
//  NewFusionSDK
//
//  Created by xiong qi on 15/11/30.
//  Copyright © 2015年 xiongqi. All rights reserved.
//

#import "NFSNSString+URL.h"
#import "NFSNSData+URL.h"
#import "NFSNSDictionary+URL.h"
#import <CommonCrypto/CommonHMAC.h>


@implementation NSString (URL)

- (NSString *)stringByAppendingQuery:(NSDictionary *)query key:(NSString *)key {
    return [self stringByAppendingFormat:@"?%@", [[self queriesWithQueries:query key:key] urlEncodedKeyValueString]];
}

- (NSString *)stringByAppendingQuery:(NSDictionary *)query postdata:(NSData *)postdata key:(NSString *)key
{
    return [self stringByAppendingFormat:@"?%@", [[self queriesWithQueries:query postdata:postdata key:key] urlEncodedKeyValueString]];
}

#pragma mark
- (NSDictionary *)queriesWithQueries:(NSDictionary *)queries key:(NSString *)key {
    if (key == nil) {
        return queries;
    }
    
    NSMutableString * content = [NSMutableString string];
    NSMutableDictionary * mutableQueries = [NSMutableDictionary dictionaryWithDictionary:queries];
    if (nil == [mutableQueries objectForKey:@"e"]) {
        [mutableQueries setObject:[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]] forKey:@"e"];
    }
    for (NSString * key in [mutableQueries.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        [content appendString:[NSString stringWithFormat:@"%@", [mutableQueries objectForKey:key]]];
    }
    
    NSData * keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData * contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char * buffer = malloc(20);
    CCHmac(kCCHmacAlgSHA1, keyData.bytes, keyData.length, contentData.bytes, contentData.length, buffer);
    [mutableQueries setObject:[[NSData dataWithBytesNoCopy:buffer length:20 freeWhenDone:YES] base64EncodedString] forKey:@"key"];
    
    return mutableQueries;
}

- (NSDictionary *)queriesWithQueries:(NSDictionary *)queries postdata:(NSData *)postdata key:(NSString *)key {
    if (key == nil) {
        return queries;
    }
    
    NSMutableString * content = [NSMutableString string];
    NSMutableDictionary * mutableQueries = [NSMutableDictionary dictionaryWithDictionary:queries];
    if (nil == [mutableQueries objectForKey:@"e"]) {
        [mutableQueries setObject:[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]] forKey:@"e"];
    }
    for (NSString * key in [mutableQueries.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        [content appendString:[NSString stringWithFormat:@"%@", [mutableQueries objectForKey:key]]];
    }
    
    NSData * keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData * contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData * mutablecontent = [NSMutableData dataWithData:contentData];
    if (postdata.length > 0) {
        [mutablecontent appendData:postdata];
    }
    
    unsigned char * buffer = malloc(20);
    CCHmac(kCCHmacAlgSHA1, keyData.bytes, keyData.length, mutablecontent.bytes, mutablecontent.length, buffer);
    [mutableQueries setObject:[[NSData dataWithBytesNoCopy:buffer length:20 freeWhenDone:YES] base64EncodedString] forKey:@"key"];
    
    return mutableQueries;
}

- (NSString *)base64EncodedString {
    
    NSData * resultData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString* encodeResult = [resultData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodeResult;
}

- (NSString *)md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5String];
}

- (NSString *)urlEncodedString {
    
    //    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
    //                                                                                (__bridge CFStringRef) self,
    //                                                                                nil,
    //                                                                                CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
    //                                                                                kCFStringEncodingUTF8);
    
    NSCharacterSet *URLBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| "] invertedSet];
    
    return [self stringByAddingPercentEncodingWithAllowedCharacters:URLBase64CharacterSet];
}


- (NSString *)urlDecodingString
{
    NSString *result = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}


- (NSMutableDictionary*)parserQueryText
{
    NSMutableDictionary* paramDic = [NSMutableDictionary new];
    const char* queryPtr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableString* name = nil;
    NSMutableString* value = nil;
    NSMutableString* temp = nil;
    for(NSInteger index = 0; index < [self length]; index++,queryPtr++)
    {
        switch ((*queryPtr))
        {
            case '=':
            {
                name = temp;
                temp = nil;
            }
                break;
            case '&':
            {
                value = temp;
                temp = nil;
                if(name)
                {
                    [paramDic setValue:[value urlDecodingString] forKey:name];
                }
            }
                break;
            default:
            {
                if(temp == nil)
                    temp = [NSMutableString new];
                [temp appendFormat:@"%c",*queryPtr];
            }
                break;
        }
    }
    if(name != nil && temp != nil)
    {
        [paramDic setObject:[temp urlDecodingString] forKey:name];
    }

    queryPtr = NULL;
    return paramDic;
}

- (NSString*)stringByRemovingEncryptQuery {
    
    NSMutableString * dataString = [NSMutableString stringWithString:self] ;
    if (0 < dataString.length) {
        [dataString replaceOccurrencesOfString:@"key=.*?&" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, dataString.length)];
        [dataString replaceOccurrencesOfString:@"e=.*?&" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, dataString.length)];
        [dataString replaceOccurrencesOfString:@"&key=.*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, dataString.length)];
        [dataString replaceOccurrencesOfString:@"&e=.*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, dataString.length)];
        return dataString;
    }
    return nil;
}
@end
