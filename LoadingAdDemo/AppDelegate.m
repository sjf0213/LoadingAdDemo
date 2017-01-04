//
//  AppDelegate.m
//  LoadingAdDemo
//
//  Created by 宋炬峰 on 2016/12/26.
//  Copyright © 2016年 appfactory. All rights reserved.
//

#import "AppDelegate.h"
#import "StartingADController.h"
#import "PreDownloader.h"
#import "UIImage+Snapshot.h"
#import "VideoADController.h"

@interface AppDelegate ()
@property(strong, nonatomic)UINavigationController* adNavi;
@property(strong, nonatomic)UINavigationController* mainNavi;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // window加载开屏广告，开屏广告dismiss之后再初始化并加载主页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadingViewDismissed) name:kLoadingViewDismissNotification object:nil];
    
    
    
    //StartingADController *adController = [[StartingADController alloc] init];
    //adController.cacheDirPath = [PreDownloader shareInstance].cacheDir;
    
    VideoADController* adController = [[VideoADController alloc] init];
    
    self.adNavi = [[UINavigationController alloc] initWithRootViewController:adController];
    self.adNavi.navigationBarHidden = YES;
    self.adNavi.interactivePopGestureRecognizer.enabled = YES;
     
     
    
    
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:self.adNavi];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)onLoadingViewDismissed{
    //    NSLog(@"-----remove loading ad, set main----");
    
    // 创建核心业务主界面
    self.mainNavi = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    self.mainNavi.navigationBarHidden = YES;
    self.mainNavi.interactivePopGestureRecognizer.enabled = YES;
    UIViewController *rootVC = self.mainNavi.topViewController;
    self.window.rootViewController = self.mainNavi;
    // 开屏图的渐隐动画效果，采用截图方式完成，因为此时StartingADController即将销毁
    [self viewDisappearAnimationWith:rootVC];
    self.adNavi = nil;
}

- (void)viewDisappearAnimationWith: (UIViewController *)VC{
    
    UIView* v = self.adNavi.topViewController.view;
    if([v isKindOfClass:[UIView class]]){
        UIImageView* fadingView = [[UIImageView alloc] initWithImage:[UIImage fb_imageForView:v]];
        fadingView.alpha = 1.0;
        [VC.view addSubview:fadingView];
        [UIView animateWithDuration:0.5 animations:^{
            fadingView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [fadingView removeFromSuperview];
        }];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
