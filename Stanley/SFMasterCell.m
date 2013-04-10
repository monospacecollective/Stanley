//
//  SFMasterTableViewCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFMasterCell.h"
#import "SFStyleManager.h"

@implementation SFMasterCell

#pragma mark - UIView

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    [self.contentView pinToSuperviewEdgesWithInsets:self.padding];
    [self.backgroundView pinToSuperviewEdgesWithInsets:self.backgroundViewPadding];
    
    [self.title centerInContainerOnAxis:NSLayoutAttributeCenterY];
    [self.icon centerInContainerOnAxis:NSLayoutAttributeCenterY];
    
    [self.icon sizeToFit];
    
    if (self.accessoryView) {
        [self.accessoryView centerInContainerOnAxis:NSLayoutAttributeCenterY];
        NSDictionary *views = @{ @"title" : self.title, @"icon" : self.icon, @"accessory" : self.accessoryView };
        NSDictionary *metrics = @{ @"iconWidth" : @(CGRectGetWidth(self.icon.frame)), @"contentMargin" : @(self.contentMargin), @"accessoryWidth" : @(CGRectGetWidth(self.accessoryView.frame)) };
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[icon(==iconWidth)]-contentMargin-[title]-contentMargin-[accessory(==accessoryWidth)]|" options:0 metrics:metrics views:views]];
    } else {
        NSDictionary *views = @{ @"iconWidth" : @(CGRectGetWidth(self.icon.frame)), @"title" : self.title, @"icon" : self.icon };
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[icon(==iconWidth)]-contentMargin-[title]|" options:0 metrics:nil views:views]];
    }
}

#pragma mark - MSTableCell

- (void) initialize
{
    [super initialize];
    
    self.icon = [UILabel new];
    self.icon.backgroundColor = [UIColor clearColor];
    self.icon.font = [[SFStyleManager sharedManager] symbolSetFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 24.0 : 20.0)];
    self.icon.textColor = [UIColor whiteColor];
    self.icon.textAlignment = NSTextAlignmentCenter;
    self.icon.shadowColor = [UIColor blackColor];
    self.icon.shadowOffset = CGSizeMake(0.0, -1.0);
    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.icon];
}

+ (CGFloat)height
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 52.0 : 44.0);
}

@end
