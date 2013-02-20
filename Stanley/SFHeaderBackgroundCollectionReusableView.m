//
//  SFHeaderBackgroundCollectionReusableView.m
//  Stanley
//
//  Created by Eric Horacek on 2/19/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFHeaderBackgroundCollectionReusableView.h"
#import "SFStyleManager.h"

@implementation SFHeaderBackgroundCollectionReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[SFStyleManager sharedManager] viewBackgroundColor];
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.borderColor = [[UIColor colorWithWhite:0.15 alpha:1.0] CGColor];
        self.layer.borderWidth = 1.0;
    }
    return self;
}

@end
