//
//  CustomWebViewController.h
//  Currency
//
//  Created by yingmin zhu on 14-9-16.
//
//

#import <UIKit/UIKit.h>

@interface CustomWebViewController : UIViewController

@property(nonatomic, copy)void (^dismissHandler)(void);

- (id)initWithFrame:(CGRect)frame withUrl:(NSString *)url;
@end
