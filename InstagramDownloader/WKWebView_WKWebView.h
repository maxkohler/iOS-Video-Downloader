//
//  WKWebView_WKWebView.h
//  InstagramDownloader
//
//  Created by max on 23/07/16.
//  Copyright © 2016 max kohler. All rights reserved.
//

@import WebKit;

@interface WKWebView(SynchronousEvaluateJavaScript)
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
@end

@implementation WKWebView(SynchronousEvaluateJavaScript)

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    __block NSString *resultString = nil;
    __block BOOL finished = NO;
    
    [self evaluateJavaScript:script completionHandler:^(id result, NSError *error)
    {
        if (error == nil)
        {
            if (result != nil)
            {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        }
        else
        {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];
    
    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return resultString;
}
@end
