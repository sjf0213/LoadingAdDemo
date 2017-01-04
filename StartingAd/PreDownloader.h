//
//  PreDownloader.h
//  Currency
//
//  Created by 宋炬峰 on 16/4/27.
//  Copyright © 2016年 appdream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreDownloader : NSObject

@property (nonatomic, strong) NSString* cacheDir;
@property (strong, atomic) NSArray* adImageURLs;

+ (PreDownloader*)shareInstance;

@end
