//
//  ViewController.h
//  InstagramDownloader
//
//  Created by max on 16/03/16.
//  Copyright © 2016 max kohler. All rights reserved.
//

@import UIKit;
@import WebKit;

@interface ViewController : UIViewController <UIWebViewDelegate, NSURLSessionDownloadDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, WKNavigationDelegate, WKUIDelegate>


@end

