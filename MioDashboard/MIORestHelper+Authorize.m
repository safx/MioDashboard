//
//  MIORestHelper+Authorize.m
//  MioDashboard
//
//  Created by Safx Developer on 2014/10/16.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

#import "MIORestHelper+Authorize.h"

@interface MIORestHelper () <UIWebViewDelegate>
@end


@implementation MIORestHelper (WebAuthorize)

- (RACSignal*)authorize {
    UIWindow* window = UIApplication.sharedApplication.windows[0];
    UIView* view = [window.rootViewController.childViewControllers[0] view];
    return [self authorizeInView:view];
}

- (RACSignal*)authorizeInView:(UIView*)view {
    UIWebView* webview = [[UIWebView alloc] init];
    webview.delegate = self;
    [webview loadRequest:self.authorizeRequest];
    
    [view addSubview:webview];
    webview.frame = view.frame;
    
    self.authSignal = [RACSubject subject];
    return [self.authSignal finally:^{
        webview.delegate = nil;
        [webview removeFromSuperview];
    }];
}

#pragma mark - WebViewDelegate for OAuth2

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL* redirect = [NSURL URLWithString:self.redirectURI];
    if ([request.URL.host isEqualToString:redirect.host]) {
        if ([self checkAccessToken:request.URL]) {
            [self.authSignal sendCompleted];
        } else {
            [self.authSignal sendError:nil];
        }
    }
    return TRUE;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.authSignal sendError:error];
}

@end
