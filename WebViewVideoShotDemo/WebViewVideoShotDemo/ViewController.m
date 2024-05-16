//
//  ViewController.m
//  WebViewVideoShotDemo
//
//  Created by 孙兴国 on 2024/5/16.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

#define ScreenWidth       [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight      [[UIScreen mainScreen] bounds].size.height

#define kColorRGBARatio(r, g, b, a)          [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:(a)]

static NSString * const blbl = @"https://www.bilibili.com/video/BV1rh411i7tz";
static NSString * const ytb = @"https://www.youtube.com/watch?v=kVWYfY8pDGA";

@interface ViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIButton *actionBtn;

@property (nonatomic, strong) NSTimer *screenShotTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}

- (void)actionBtnClick:(UIButton *)button {
    
    button.selected = !button.selected;
    
    if (button.selected) {
        [self startScreenShot];
    } else {
        [self stopScreenShot];
    }
}

- (void)createUI {
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.actionBtn];
    [self.view addSubview:self.previewImageView];
}

- (void)startScreenShot {
    
    if (!self.webView.URL) {
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:blbl]]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 延迟5秒，为了等待网页大致载入完成，操作视频播放后开始截屏
            [self startRecordScreenWithView:self.webView];
        });
    } else {
        [self startRecordScreenWithView:self.webView];
    }
}

- (void)startRecordScreenWithView:(UIView *)recordView {
    
    self.screenShotTimer = [NSTimer scheduledTimerWithTimeInterval:1.f / 20 target:self selector:@selector(screenshot) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.screenShotTimer forMode:NSRunLoopCommonModes];
    
    NSLog(@"开始截图 ---------------");
}

- (void)screenshot {
    
    @autoreleasepool {
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
            UIGraphicsBeginImageContextWithOptions(_webView.bounds.size, NO, [UIScreen mainScreen].scale);
        } else {
            UIGraphicsBeginImageContext(_webView.bounds.size);
        }
        BOOL success = [_webView drawViewHierarchyInRect:_webView.bounds afterScreenUpdates:NO];
        if (!success) {
            NSLog(@"截图失败!!!");
            return;
        }
        //[view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _previewImageView.image = image;
        image = nil;
    }
}

- (void)stopScreenShot {
    
    if (self.screenShotTimer) {
        [self.screenShotTimer invalidate];
        self.screenShotTimer = nil;
    }
    
    _previewImageView.image = nil;
}

#pragma mark - 懒加载
- (WKWebView *)webView {
    
    if (!_webView) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.allowsInlineMediaPlayback = YES; // 不强制全屏播放
        config.mediaTypesRequiringUserActionForPlayback = NO; // 自动开始播放
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 100, ScreenWidth, 300) configuration:config];
        _webView.backgroundColor = kColorRGBARatio(244, 244, 244, 1);
        _webView.layer.borderColor = UIColor.blackColor.CGColor;
        _webView.layer.borderWidth = 0.5;
    }
    return _webView;
}

- (UIImageView *)previewImageView {
    
    if (!_previewImageView) {
        
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 300) / 2, 500, 300, 200)];
        _previewImageView.backgroundColor = kColorRGBARatio(244, 244, 244, 1);
        _previewImageView.layer.borderColor = UIColor.redColor.CGColor;
        _previewImageView.layer.borderWidth = 0.5;
    }
    return _previewImageView;
}

- (UIButton *)actionBtn {
    
    if (!_actionBtn) {
        
        _actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionBtn.frame = CGRectMake((self.view.bounds.size.width - 120) / 2, 430, 120, 40);
        _actionBtn.backgroundColor = UIColor.blueColor;
        [_actionBtn setTitle:@"开始截图" forState:UIControlStateNormal];
        [_actionBtn setTitle:@"停止截图" forState:UIControlStateSelected];
        _actionBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_actionBtn addTarget:self action:@selector(actionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionBtn;
}

@end
