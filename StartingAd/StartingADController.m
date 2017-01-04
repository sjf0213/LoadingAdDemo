//
//  StartingADController.m
//  Currency
//
//  Created by 宋炬峰 on 16/4/21.
//  Copyright © 2016年 appdream. All rights reserved.
//

//0、程序启动后，显示系统启动图，即白图，不在程序控制范围内，不计时
//
//1、程序进入控制范围，即loading开始，预留4秒时间，更新服务器上adconfig（不读缓存）
//
//2、如果adconfig更新失败，程序直接跳过loading，失败情况如下：
//2.1 网络所有失败
//2.2 更新超时，即超过4秒预留时间
//2.3 adconfig更新完成，但不存在有效广告
//2.4 adconfig更新完成，存在有效广告，但是广告的duration无效或者小于adconfig更新时间
//
//3、如果adconfig更新完成并有有效广告，读取adconfig中广告的duration时间，作为总体的loading时限，其中包括时间如下：
//3.1 adconfig更新时间
//3.2 广告图片下载时间
//3.3 广告图片显示时间
//注：此时loading剩余时间 ＝ duration － 更新adconfig的时间
//
//4、如果图片下载失败，程序直接跳过loading，失败情况如下：
//4.1 网络所有失败
//4.2 下载超时，即超过loading剩余时间
//注：下载超时，也会继续下载，直到下载成功或失败
//
//5、当广告图片下载完毕后显示的时限不能小于1秒，即loading的总时间最大不超过duration＋1秒
//注：当显示图片的时间 ＝ MAX（1，duration － 更新adconfig的时间－下载广告图片的时间）
//
//6、当用户点击广告图片，无论是内部弹出视图后关闭视图，还是外部跳出后回到程序，直接跳过loading。

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "StartingADController.h"
#import "CocoaSecurity.h"
#import "DeviceHelper.h"
#import "CustomWebViewController.h"
#import "PreDownloader.h"
#import "UrlReplaceHelp.h"
#import "DACircularProgressView.h"
#import "NFSNSString+URL.h"
#import "LoadingAdModel.h"

CGFloat const DefaultShowTime = 5.0f;

static NSString* const LH_HOST = @"http://172.18.1.221";
static NSString* const EncyptKey = @"(66qdorPfAG7#XjN3=Fac]";

NSString* const kLoadingViewDismissNotification = @"kLoadingViewDismissNotification";
NSString* const LHLoadingAdLastModifiedTimeStamp = @"LHLoadingAdLastModifiedTimeStamp";

static CGFloat kDefaultLoadingTimeInterval = 3.0;
static CGFloat kMinLoadingTimeInterval = 1.0;

@interface StartingADController ()<SKStoreProductViewControllerDelegate>
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIImage *loadingImage;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIImageView *startView;
@property (nonatomic, strong) UIImageView *contentImageView;
//@property (nonatomic, assign) BOOL touchflag;//是否点击消失
@property (nonatomic, assign) int loadingTimeInterval;
@property (nonatomic, assign) BOOL isExpire;
@property (nonatomic, strong) NSString * filename;

@property (nonatomic, strong) NSString* cacheDir;
@property (nonatomic, strong) NSDate* beginShowTime;
@property (atomic,    strong) NSTimer   * dismissTimer;
@property (nonatomic, strong) LoadingAdModel* adModel;

@property (nonatomic, strong) DACircularProgressView* circle;

@end

@implementation StartingADController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    // 创建广告视图
    [self showLoadingPlaceHolder];
    
    // 如果缓存目录不存在，创建目录
    NSArray* dirArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentPath = [dirArray objectAtIndex:0];
    self.cacheDir = [documentPath stringByAppendingPathComponent:@"StartImages"];
    
    // 检查配置文件
    [self performSelector:@selector(actionForCheckLoading) withObject:nil afterDelay:0];

    // 清理过时的缓存文件
    [self cleanCache:self.cacheDir];
}

- (void)showLoadingPlaceHolder{
    
//    NSLog(@"记录开始展示loading的时间");
    self.beginShowTime = [NSDate date];// 记录开始展示loading的时间
    [self updateDismissTimerWithInterval:kDefaultLoadingTimeInterval];
    
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.loadingView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
    
    self.startView = [[UIImageView alloc] initWithFrame:_loadingView.bounds];
    NSString*  imageName = @"";
    NSUInteger h = (NSUInteger)CGRectGetHeight([UIScreen mainScreen].bounds);
    switch (h) {
        case 480:
            imageName = @"LaunchImage-700";
            break;
        case 568:
            imageName = @"LaunchImage-700-568h";
            break;
        case 667:
            imageName = @"LaunchImage-800-667h";
            break;
        case 736:
            imageName = @"LaunchImage-800-Portrait-736h";
            break;
        case 1024:
            imageName = @"LaunchImage-700-Portrait";
            break;
        default:
            break;
    }
    self.startView.image = [UIImage imageNamed:imageName];
    [self.loadingView addSubview:self.startView];
    
    self.contentImageView = [[UIImageView alloc] initWithFrame:self.loadingView.bounds];
    [self.loadingView addSubview:self.contentImageView];
    self.contentImageView.image = nil;
    self.contentImageView.alpha = 0;
    
    self.skipButton = [[UIButton alloc] initWithFrame:CGRectMake(self.loadingView.bounds.size.width - 50-20, 20, 44, 44)];
    [self.skipButton.titleLabel setTextColor:[UIColor whiteColor]];
    [self.skipButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.skipButton setTitle:@"跳过" forState:UIControlStateNormal];
    self.skipButton.layer.cornerRadius = 0.5*self.skipButton.bounds.size.height;
    self.skipButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.skipButton addTarget:self action:@selector(onTapSkip) forControlEvents:UIControlEventTouchUpInside];
    self.skipButton.alpha = 0.0;
    [self.loadingView addSubview:self.skipButton];
    
    self.circle = [[DACircularProgressView alloc] initWithFrame:CGRectMake(2, 2, self.skipButton.bounds.size.width - 4, self.skipButton.bounds.size.height - 4)];
    self.circle.trackTintColor = [UIColor clearColor];
    self.circle.progressTintColor = [UIColor whiteColor];
    self.circle.thicknessRatio = 1/22.0;
    self.circle.clockwiseProgress = NO;
    self.circle.userInteractionEnabled = NO;
    [self.skipButton addSubview:self.circle];
    
    [self.view addSubview:self.loadingView];
    [self.view bringSubviewToFront:self.loadingView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEvent)];
    [self.loadingView addGestureRecognizer:tap];
}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

-(void)actionForCheckLoading
{
    NSMutableDictionary * finalBizData = [NSMutableDictionary dictionaryWithCapacity:7];
    [finalBizData setObject:[DeviceHelper shareInstance].cliendTypeID forKey:@"clientid"];
    [finalBizData setObject:[DeviceHelper shareInstance].deviceModel forKey:@"device"];
    [finalBizData setObject:[DeviceHelper shareInstance].systemVersion forKey:@"iosver"];
    [finalBizData setObject:[DeviceHelper shareInstance].appver forKey:@"appver"];
    [finalBizData setObject:@"1" forKey:@"json"];

    NSString* urlbase = [NSString stringWithFormat:@"%@/client/adlist/start", LH_HOST];
    NSString* urlpath = [urlbase stringByAppendingQuery:finalBizData key:EncyptKey];

    __weak typeof(self)wself = self;
    NSLog(@"downloadLoading urlpath %@",urlpath);
    NSURL *url = [NSURL URLWithString:urlpath];
    
    NSLog(@"-----------------------开屏广告url %@",url);
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kDefaultLoadingTimeInterval];
    
    // 加入Header 写入本地记录的上次请求数据返回的Last-Modified时间到Header中的If-Modified-Since
    [self addHeaderForModifyTime:request];
    
    // 同步等待的请求
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    // 发出请求
    NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error){
        
        if (error == nil){
            
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                
                // 200，存储下来Response，为将来304的情况做准备
                if (200 == httpResponse.statusCode) {
                    
                    // 正常处理数据
                    [wself processSuccessWithResponseData:responseData response:response error:error];
                    
                    // 存储response
                    [wself storeResponse:httpResponse responseData:responseData error:nil];
                }
                // 304， 读取缓存数据，当做成功返回处理
                if (304 == httpResponse.statusCode) {
                    
                    NSString* urlNoEncrypt = [url.absoluteString stringByRemovingEncryptQuery];
                    NSURLRequest* requestNoEncript = [NSURLRequest requestWithURL:[NSURL URLWithString:urlNoEncrypt]];
                    NSCachedURLResponse* cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:requestNoEncript];
                    if ([cachedResponse isKindOfClass:[NSCachedURLResponse class]]) {
                        [wself processSuccessWithResponseData:cachedResponse.data response:cachedResponse.response error:nil];
                    }
                }
            }
        }else{
            //2.1 网络所有失败
            //2.2 更新超时，即超过4秒预留时间
            //NSLog(@"2.1, 2.2 adconfig网络请求出错或者超时");
            [wself.dismissTimer fire];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

-(void)addHeaderForModifyTime:(NSMutableURLRequest*)request{
    NSString* urlNoEncrypt = [request.URL.absoluteString stringByRemovingEncryptQuery];
    NSURLRequest* requestNoEncript = [NSURLRequest requestWithURL:[NSURL URLWithString:urlNoEncrypt]];
    NSString* diskTimeRecord = [[NSUserDefaults standardUserDefaults] valueForKey:LHLoadingAdLastModifiedTimeStamp];
    NSCachedURLResponse* cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:requestNoEncript];
    // 本地有请求的旧缓存，且有modify时间的时候才插入If-Modified-Since
    if ([cachedResponse isKindOfClass:[NSCachedURLResponse class]] &&
        [diskTimeRecord isKindOfClass:[NSString class]] &&
        diskTimeRecord.length > 0) {
        [request addValue:diskTimeRecord forHTTPHeaderField:@"If-Modified-Since"];
    }
}

-(void)storeResponse:(NSHTTPURLResponse *)response responseData:(NSData *) responseData error:(NSError*)error{
    NSCachedURLResponse* cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:responseData];
    
    NSString* urlNoEncrypt = [response.URL.absoluteString stringByRemovingEncryptQuery];
    NSURLRequest* requestNoEncript = [NSURLRequest requestWithURL:[NSURL URLWithString:urlNoEncrypt]];
    [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:requestNoEncript];
    
    // 记录请求返回response中Header的Last-Modified时间到本地
    NSDictionary* headerDic = response.allHeaderFields;
    NSString* timeStamp = headerDic[@"Last-Modified"];
    [[NSUserDefaults standardUserDefaults] setValue:timeStamp forKey:LHLoadingAdLastModifiedTimeStamp];
}

-(void)processSuccessWithResponseData:(NSData *)responseData response:(NSURLResponse *)response error:(NSError*)error{
    
    NSDictionary * value = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"-----------------------loading config value %@",value);
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSArray* v = value[@"v"];
        if ([v isKindOfClass:[NSArray class]]) {
            NSMutableArray* modelArr = [NSMutableArray array];
            for (NSDictionary* dic in v) {
                LoadingAdModel* adModel = [[LoadingAdModel  alloc] initWithDic:dic];
                [modelArr addObject:adModel];
            }
            
            // 找一个随机广告进行展示
            NSInteger rand = [self getRandomNumber:0 to:(int)(v.count) - 1];
            LoadingAdModel* adModel = modelArr[rand];
            __weak typeof(self)wself = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [wself tryDownloadAndRefresh:adModel];
            });
            
            // 所有广告，都预先下载,为了以后启动时候显示
            [self prepareDownload:modelArr];
            
        }else{
            //2.3 adconfig更新完成，但不存在有效广告
            [self.dismissTimer fire];
        }
    }else{
        //2.3 adconfig更新完成，但不存在有效广告
        [self.dismissTimer fire];
    }
}

// 所有广告，都预先下载, 为了以后启动时候显示
-(void)prepareDownload:(NSMutableArray* )modelArr{
    NSMutableArray* predownArr = [NSMutableArray array];
    for (LoadingAdModel* model in modelArr) {
        NSString* url = model.imgURL;
        NSUInteger h = (NSUInteger)CGRectGetHeight([UIScreen mainScreen].bounds);
        if (480 == h) {
            url = model.imgURL_4s;
        }
        if ([url isKindOfClass:[NSString class]]) {
            [predownArr addObject:url];
        }
    }
    if ([predownArr isKindOfClass:[NSArray class]] && predownArr.count > 0) {
        //DLog(@"---------pre download list: %@", predownArr);
        [PreDownloader shareInstance].adImageURLs = predownArr;
    }
}

-(void)cleanCache:(NSString*)dir{
    // 遍历缓存目录，删除修改时间超过一个月的文件
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnumerater = [fm enumeratorAtPath:dir];
    NSString *filePath = nil;
    while(nil != (filePath = [dirEnumerater nextObject])) {
        
        NSString *fulldir = [NSString stringWithFormat:@"%@/%@",self.cacheDir,filePath];
        NSDictionary *attributes = [fm attributesOfItemAtPath:fulldir error:nil];
        NSDate *theModifiDate;
        if ((theModifiDate = [attributes objectForKey:NSFileModificationDate])) {
            if (0 - [theModifiDate timeIntervalSinceNow] > 3600*24*30) {
                NSError* error = nil;
                /*BOOL flag = */[fm removeItemAtPath:fulldir error:&error];
//                NSLog(@"[Loading]delete loading cache file result :%d, path: %@", flag, fulldir);
            }
        }
    }
}

- (BOOL)downloadimage:(NSString *)url
{
    //以url编码md5作为文件名的图片是否存在,存在则不用下载
    CocoaSecurityResult * result = [CocoaSecurity md5:url];
    NSString * md5url = result.hex;
    NSString * filename = [self.cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", md5url]];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filename]) {
//        NSLog(@"%@, 正式loading图cache中已经存在,不需要下载", md5url);
        return YES;
    }else{
        // 下载图片文件
        NSData * imagedata = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if (imagedata) {
            BOOL flag = [imagedata writeToFile:filename atomically:YES];
//            NSLog(@"%@, 正式loading图下载写入文件结果：%d", md5url, flag);
            return flag;
        }else{
//            NSLog(@"%@, 正式loading图下载结果：NSData == nil", md5url);
            return NO;
        }
    }
    return NO;
}

-(void)tryDownloadAndRefresh:(LoadingAdModel*)adModel{
    // 要显示的loading图尺寸
    NSString* url = adModel.imgURL;
    NSUInteger h = (NSUInteger)CGRectGetHeight([UIScreen mainScreen].bounds);
    if (480 == h) {
        url = adModel.imgURL_4s;
    }
    
    if ([self downloadimage:url]){
        //更新广告显示
        CocoaSecurityResult * result = [CocoaSecurity md5:url];
        NSString * targetUrlMD5 = result.hex;
        NSString * targetFileName = [self.cacheDir stringByAppendingPathComponent:targetUrlMD5];
        [self refreshAd:targetFileName withShowTime:adModel.showTime];
    }
}

- (void)refreshAd:(NSString*)filename withShowTime:(NSTimeInterval)t
{
    
     __weak typeof(self)wself = self;
    self.loadingImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:filename]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([wself.loadingImage isKindOfClass:[UIImage class]]) {
            //在开屏广告视图上加载有效的广告；
//            NSLog(@"在开屏广告视图上加载有效的广告");
            NSDate* now = [NSDate date];
            NSTimeInterval flowedTime = [now timeIntervalSinceDate:wself.beginShowTime];
            
            CGFloat showtime = DefaultShowTime;
            if(t > 0){
                showtime = t;
            }
            NSLog(@"展示广告前已经流失的时间flowedTime = %f, 配置展示时间showtime = %f", flowedTime, showtime);
            if (flowedTime > showtime) {
                //2.4 adconfig更新完成，存在有效广告，但是广告的duration无效或者小于adconfig更新时间, 直接关闭开屏广告视图；
//                    NSLog(@"但是广告的duration无效或者小于adconfig更新时间, 直接关闭开屏广告视图");
                [wself.dismissTimer fire];
            }else{// 展示广告
                CGFloat targetShowTime = showtime - flowedTime;
                targetShowTime = MAX(kMinLoadingTimeInterval, targetShowTime);
                NSLog(@"---展示广告---展示时间:%f", targetShowTime);
                CGFloat prog = (showtime - targetShowTime)/showtime;
                [self.circle setProgress: (1.0 - prog)];
                [self.circle setProgress: 0.0 animated:YES initialDelay:0 withDuration:targetShowTime];
                [wself updateDismissTimerWithInterval:targetShowTime];
                wself.contentImageView.image = wself.loadingImage;
                [UIView animateWithDuration:.3 animations:^{
                    [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
                    wself.contentImageView.alpha = 1;
                    wself.skipButton.alpha = 1.0;
                } completion:^(BOOL finished) {
                    
                    [[UIApplication sharedApplication]endIgnoringInteractionEvents];
                }];
            }
        }else{
            //直接关闭开屏广告视图；
            [wself.dismissTimer fire];
        }
    });
}

- (void)updateDismissTimerWithInterval:(NSTimeInterval)interval {
    [self.dismissTimer invalidate];
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(onDismissLoading) userInfo:nil repeats:NO];
}

#pragma mark - dismiss


- (BOOL)isDismissedLoading {
    return nil == self.dismissTimer || ! [self.dismissTimer isValid];
}

- (void)onDismissLoading {
    if (! self.isDismissedLoading) {
        [self.dismissTimer invalidate];
        self.dismissTimer = nil;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadingViewDismissNotification object:nil];
    });
}

#pragma mark - Touch Events

-(void)handleEvent
{
    if (self.contentImageView.image == nil) {
        return;
    }
    //开屏广告类型
    if ([self.adModel isKindOfClass:[LoadingAdModel class]]) {
        [self handleAdTap:self.adModel];
    }
}

- (void)handleAdTap:(LoadingAdModel*)adModel{
    if ([adModel isKindOfClass:[LoadingAdModel class]]) {
        NSInteger n = adModel.jumpType;
        switch (n) {
            case LoadingAdJump_InnerWeb:{
                NSString* urlStr = [[UrlReplaceHelp sharedInstance] replaceurl:adModel.link];
                if ([urlStr isKindOfClass:[NSString class]]) {
                    CustomWebViewController* controller = [[CustomWebViewController alloc] initWithFrame:[UIScreen mainScreen].bounds withUrl:urlStr];
                    __weak typeof(self)wself = self;
                    controller.dismissHandler = ^{
                        [wself.dismissTimer fire];
                    };
                    [self.navigationController pushViewController:controller animated:YES];
                    [self updateDismissTimerWithInterval:[NSDate distantFuture].timeIntervalSinceNow];
                }
            }
                break;
            case LoadingAdJump_Safari:{
                NSString* str = [[UrlReplaceHelp sharedInstance] replaceurl:adModel.link];
                if ([str isKindOfClass:[NSString class]]) {
                    NSURL* url = [NSURL URLWithString:str];
                    if ([url isKindOfClass:[NSURL class]]) {
                        if ([UIDevice currentDevice].systemVersion.doubleValue >= 10.0f) {
                            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                        }else{
                            [[UIApplication sharedApplication] openURL:url];
                        }
                        
                    }
                }
                [self.dismissTimer fire];
            }
                break;
            default:
                break;
        }
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self.dismissTimer fire];
}

- (void)onTapSkip{
    [self.dismissTimer fire];
}

- (void)dealloc
{
//    NSLog(@" StartingADController dealloc - - - - - -");
}
@end
