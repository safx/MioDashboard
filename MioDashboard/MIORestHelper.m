//
//  MIOOAuthModel.m
//  MioGraph
//
//  Created by Safx Developer on 2013/12/27.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIORestHelper.h"
#import <AFNetworking.h>
#import <AFNetworking-RACExtensions/RACAFNetworking.h>

@interface MIORestHelper () <UIWebViewDelegate>
@property RACSubject* authSignal;
@end

@implementation MIORestHelper

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
             @"couponInfo":NSNull.null,
             @"packetInfo":NSNull.null,
             @"state":NSNull.null,
             @"authSignal":NSNull.null
    };
}

+ (MIORestHelper*)sharedInstance {
    __block MIORestHelper* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self loadAccessToken];
        if (!instance) {
            instance = MIORestHelper.alloc.init;
            instance.clientID = @"<Your CliendID>";
            instance.redirectURI = @"<Your Redirect URI>";
        }
    });
    return instance;
}

#pragma mark - serialization

+ (NSString*)serverPath {
    NSString* home = NSHomeDirectory();
    return [home stringByAppendingPathComponent:@"Library/Caches/iij.json"];
}

+ (void)saveAccessToken:(MIORestHelper*)instance {
    NSError* error = nil;
    NSDictionary* dic = [MTLJSONAdapter JSONDictionaryFromModel:instance];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    if (!error) {
        [data writeToFile:self.serverPath atomically:YES];
    }
}

+ (MIORestHelper*)loadAccessToken {
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfFile:self.serverPath options:0 error:&error];
    if (error) return nil;
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) return nil;
    return [MTLJSONAdapter modelOfClass:MIORestHelper.class fromJSONDictionary:dic error:&error];
}

#pragma mark - helper funcs

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
    NSAssert(_clientID && _redirectURI && _state, @"should be non-nil.");
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

    
#pragma mark - IIJMio REST API

- (NSMutableURLRequest*)apiRequestWithURLString:(NSString*)urlString {
    NSAssert(_clientID && _accessToken, @"should be non-nil");
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];

    [request setValue:self.clientID forHTTPHeaderField:@"X-IIJmio-Developer"];
    [request setValue:self.accessToken forHTTPHeaderField:@"X-IIJmio-Authorization"];
    return request;
}

- (RACSignal*)getCoupon {
    NSMutableURLRequest* request = [self apiRequestWithURLString:@"https://api.iijmio.jp/mobile/d/v1/coupon/"];
    return [AFJSONRequestOperation rac_startJSONRequestOperationWithRequest:request];
}

- (RACSignal*)getPacket {
    NSMutableURLRequest* request = [self apiRequestWithURLString:@"https://api.iijmio.jp/mobile/d/v1/log/packet/"];
    return [AFJSONRequestOperation rac_startJSONRequestOperationWithRequest:request];
}

- (RACSignal*)putCoupon:(BOOL)useCoupon forHdoServiceCode:(NSString*)hdoServiceCode {
    NSMutableURLRequest* request = [self apiRequestWithURLString:@"https://api.iijmio.jp/mobile/d/v1/coupon/"];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString* jsonstr = [NSString stringWithFormat:@"{\"couponInfo\":[{\"hdoInfo\":[{\"hdoServiceCode\":\"%@\",\"couponUse\":%@}]}]}", hdoServiceCode, useCoupon? @"true":@"false"];
    request.HTTPBody = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
    return [AFJSONRequestOperation rac_startJSONRequestOperationWithRequest:request];
}

@end
