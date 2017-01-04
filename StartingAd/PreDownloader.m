//
//  PreDownloader.m
//  Currency
//
//  Created by 宋炬峰 on 16/4/27.
//  Copyright © 2016年 appdream. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PreDownloader.h"
#import "CocoaSecurity.h"
@implementation PreDownloader
+ (PreDownloader*)shareInstance{
    static PreDownloader* b_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        b_instance = [[PreDownloader alloc] init];
    });
    return b_instance;
}

- (id)init{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadAll) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

-(NSString*)cacheDir{
    // 存放loading广告的缓存目录
    NSArray*  dirArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString* documentPath = dirArray[0];// 必须有
    NSString* cacheDir = [documentPath stringByAppendingString:@"/StartImages"];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL flag = [fm fileExistsAtPath:cacheDir isDirectory:&isDirectory];
    if ((isDirectory && flag) == NO) {
        NSError* error = nil;
        [fm createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            //            NSLog(@"----------create cache Directory fail: %@", error.description);
        }
    }
    //    NSLog(@"----------cacheDir: %@", cacheDir);
    return cacheDir;
}

- (void)downloadAll {
//    NSLog(@"- - - - 开始检查需要预下载的AD - - - -");
    __weak typeof(self) wself = self;
    [self.adImageURLs enumerateObjectsUsingBlock:^(NSString * url, NSUInteger idx, BOOL *stop) {
        // 下载pre列表中的 urls 对应的图片文件
        if ([url isKindOfClass:[NSString class]]) {
            [wself downloadImageByUrl:url];
        }
    }];
}

-(void)downloadImageByUrl:(NSString*)url{
    //判断：需要下载的图片，在已经下载过的图片Cache文件夹是否存在
    if ([self.cacheDir isKindOfClass:[NSString class]]) {
        CocoaSecurityResult * result = [CocoaSecurity md5:url];
        NSString * targetUrlMD5 = result.hex;
        NSString * targetFileName = [self.cacheDir stringByAppendingPathComponent:targetUrlMD5];
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:targetFileName]) {
//            NSLog(@"%@, pre已经存在不需要下载", targetUrlMD5);
        }else{
            // 下载图片文件
            NSData * imagedata = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            if (imagedata) {
                /*BOOL flag = */[imagedata writeToFile:targetFileName atomically:YES];
//                NSLog(@"%@, pre下载写入文件结果：%d", targetUrlMD5, flag);
            }else{
//                NSLog(@"%@, pre下载结果：NSData == nil", targetUrlMD5);
            }
        }
    }
}
@end
