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


@implementation MIORestHelper (Authorize)

#pragma mark - OAuth2 helper funcs

- (BOOL)checkAccessToken:(NSURLRequest*)request {
    NSDictionary* params = Underscore.array([request.URL.fragment componentsSeparatedByString:@"&"]).reduce(@{}, ^(NSDictionary* a, NSString* str) {
        NSArray* kv = [str componentsSeparatedByString:@"="];
        return Underscore.extend(a, @{ kv[0]:kv[1] });
    });
    NSString* state = [self.state stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    if ([state isEqualToString:params[@"state"]]) {
        self.accessToken = params[@"access_token"];
        [MIORestHelper saveAccessToken:self];
        return TRUE;
    }
    return FALSE;
}

- (NSURLRequest*)authorizeRequest {
    NSAssert(self.clientID && self.redirectURI && self.state, @"should be non-nil.");
    NSDictionary* dic = @{@"response_type":@"token", @"client_id":self.clientID, @"redirect_uri":self.redirectURI, @"state":self.state};
    NSURLComponents* comp = [NSURLComponents componentsWithString:@"https://api.iijmio.jp/mobile/d/v1/authorization/"];
    comp.query = [Underscore.dict(dic).map(^id(id key, id obj) {
        return [NSString stringWithFormat:@"%@=%@", key, obj];
    }).values.unwrap componentsJoinedByString:@"&"];
    
    return [[NSURLRequest alloc] initWithURL:comp.URL];
}

#pragma mark - OAuth2

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
        if ([self checkAccessToken:request]) {
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
