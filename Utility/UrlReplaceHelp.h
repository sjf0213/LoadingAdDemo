//
//  UrlReplaceHelp.h
//  Weather
//
//  Created by xiongqi on 16/9/2.
//  Copyright © 2016年 Wxl.Haiyue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlReplaceHelp : NSObject

+(UrlReplaceHelp*)sharedInstance;

- (NSString *)replaceurl:(NSString *)urlString;
@end
