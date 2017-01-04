//
//  VideoADController.m
//  LoadingAdDemo
//
//  Created by 宋炬峰 on 2017/1/4.
//  Copyright © 2017年 appfactory. All rights reserved.
//

#import "VideoADController.h"
#import "DACircularProgressView.h"

@interface VideoADController()

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIImageView *startView;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) DACircularProgressView* circle;

@property (nonatomic, strong) NSDate* beginShowTime;
@property (atomic,    strong) NSTimer   * dismissTimer;
@end

static CGFloat kDefaultLoadingTimeInterval = 5.0;

@implementation VideoADController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor cyanColor];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    // 创建广告视图
    [self showLoadingPlaceHolder];
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
    
//    self.contentImageView = [[UIImageView alloc] initWithFrame:self.loadingView.bounds];
//    [self.loadingView addSubview:self.contentImageView];
//    self.contentImageView.image = nil;
//    self.contentImageView.alpha = 0;
    
    self.skipButton = [[UIButton alloc] initWithFrame:CGRectMake(self.loadingView.bounds.size.width - 50-20, 20, 44, 44)];
    [self.skipButton.titleLabel setTextColor:[UIColor whiteColor]];
    [self.skipButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.skipButton setTitle:@"跳过" forState:UIControlStateNormal];
    self.skipButton.layer.cornerRadius = 0.5*self.skipButton.bounds.size.height;
    self.skipButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.skipButton addTarget:self action:@selector(onTapSkip) forControlEvents:UIControlEventTouchUpInside];
    self.skipButton.alpha = 1.0;
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

- (void)updateDismissTimerWithInterval:(NSTimeInterval)interval {
    [self.dismissTimer invalidate];
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(onDismissLoading) userInfo:nil repeats:NO];
}


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

- (void)onTapSkip{
    [self.dismissTimer fire];
}

-(void)handleEvent
{
//    if (self.contentImageView.image == nil) {
//        return;
//    }
//    //开屏广告类型
//    if ([self.adModel isKindOfClass:[LoadingAdModel class]]) {
//        [self handleAdTap:self.adModel];
//    }
}




@end
