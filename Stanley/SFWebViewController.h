//
//  SFWebViewController.h
//  Stanley
//
//  Created by Eric Horacek on 3/8/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFWebViewController : UIViewController

@property (nonatomic, assign) BOOL scalesPageToFit;
@property (nonatomic, strong) NSString *requestURL;

@property (nonatomic, strong) UIWebView *webView;

@end
