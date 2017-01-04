//
//  CustomWebViewController.m
//  Currency
//
//  Created by yingmin zhu on 14-9-16.
//
//

#import "CustomWebViewController.h"
#import <WebKit/WebKit.h>

@interface CustomWebViewController ()<WKNavigationDelegate>
{
    UIView* topView;
    UIButton* closeBtn;
    WKWebView* webView;
    UIActivityIndicatorView* indicatorView;
    UIButton* refreshBtn;
    NSString* tempUrl;
}
@end

@implementation CustomWebViewController

- (id)initWithFrame:(CGRect)frame withUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        
        NSInteger distance = 20;
        topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 64)];
        topView.backgroundColor = [UIColor whiteColor];
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5, self.view.bounds.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [topView addSubview:line];
        [self.view addSubview:topView];
        topView.userInteractionEnabled = YES;
        
        closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, distance, 44, 44)];
        [closeBtn setImage:[UIImage imageNamed:@"StartingAD.bundle/back_btn_dark"] forState:UIControlStateNormal];
//        [closeBtn setTitle:NSLocalizedString(@"返回", @"Back") forState:UIControlStateNormal];
//        closeBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [self.view addSubview:closeBtn];
        [closeBtn addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
        
        webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(topView.frame), frame.size.width, CGRectGetHeight(frame)-CGRectGetHeight(topView.frame)-20+distance)];
        webView.navigationDelegate = self;
        [self.view addSubview:webView];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0]];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.frame = CGRectMake(0, 0, 20, 20);
        indicatorView.center = CGPointMake(CGRectGetWidth(webView.frame)/2, CGRectGetHeight(webView.frame)/2);
        [self.view addSubview:indicatorView];
        
//        refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 235/2, 45)];
//        refreshBtn.center = CGPointMake(CGRectGetWidth(webView.frame)/2, CGRectGetHeight(webView.frame)/2);
//        [refreshBtn setImage:[UIImage imageNamed:@"web_refreshBtn.png"] forState:UIControlStateNormal];
//        [self.view addSubview:refreshBtn];
//        [refreshBtn addTarget:self action:@selector(refreshWebContent:) forControlEvents:UIControlEventTouchUpInside];
//        refreshBtn.hidden = YES;
    }
    return self;
}

- (void)dismissSelf:(id)sender
{
    webView.navigationDelegate = nil;
    [webView stopLoading];
    
    if (self.dismissHandler) {
        self.dismissHandler();
    }
}

- (void)refreshWebContent:(id)sender
{
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tempUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKWebViewDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [indicatorView startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [indicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [indicatorView stopAnimating];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

@end
