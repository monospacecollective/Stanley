//
//  SFMasterTableViewCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFMasterTableViewCell.h"
#import "SFStyleManager.h"

@implementation SFMasterTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.icon = [UILabel new];
        self.icon.backgroundColor = [UIColor clearColor];
        self.icon.font = [[SFStyleManager sharedManager] symbolSetFontOfSize:20.0];
        self.icon.textColor = [UIColor whiteColor];
        self.icon.textAlignment = UITextAlignmentCenter;
        self.icon.shadowColor = [UIColor blackColor];
        self.icon.shadowOffset = CGSizeMake(0.0, -1.0);
        [self.contentView addSubview:self.icon];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat xOffset = 40.0;
    self.textLabel.frame = CGRectOffset(self.textLabel.frame, xOffset, 3.0);
    
    [self.icon sizeToFit];
    CGRect iconFrame = self.icon.frame;
    iconFrame.origin = CGPointMake(0.0, 10.0);
    iconFrame.size.width = CGRectGetMinX(self.textLabel.frame);
    self.icon.frame = iconFrame;
}

#pragma mark - MSTableViewCell

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    [super setAccessoryType:accessoryType];
    switch (accessoryType) {
        case UITableViewCellAccessoryNone: {
            [self.accessoryView removeFromSuperview];
            self.accessoryView = nil;
            break;
        }
        case UITableViewCellAccessoryDisclosureIndicator: {
            self.accessoryTextLabel.text = @"\U000025BB";
            [self.accessoryTextLabel sizeToFit];
            self.accessoryView = self.accessoryTextLabel;
            [self.contentView addSubview:self.accessoryView];
            break;
        }
        case UITableViewCellAccessoryCheckmark: {
            // Has a nice checkmark - we want to use a label so that text customization works
            self.accessoryTextLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:32.0];
            self.accessoryTextLabel.text = @"\U00002713 ";
            [self.accessoryTextLabel sizeToFit];
            self.accessoryView = self.accessoryTextLabel;
            [self.contentView addSubview:self.accessoryView];
            break;
        }
        case UITableViewCellAccessoryDetailDisclosureButton: {
            break;
        }
    }
}

@end
