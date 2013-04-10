//
//  SFPopoverBackgroundView.h
//  Stanley
//
//  Created by Eric Horacek on 4/10/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFPopoverBackgroundView : UIPopoverBackgroundView

// Negative values bring the arrow out of the popover, positive bring it into the popover
@property (nonatomic, assign) CGFloat arrowAdjustment;
@property (nonatomic, assign) CGFloat cornerRadius;

+ (CGFloat)arrowHeight;
+ (CGFloat)arrowBase;
+ (UIEdgeInsets)contentViewInsets;

@end
