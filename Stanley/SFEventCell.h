//
//  SFEventCell.h
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface SFEventCell : UICollectionViewCell

@property (nonatomic, weak) Event *event;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UILabel *location;
@property (nonatomic, strong) UILabel *timeIcon;
@property (nonatomic, strong) UILabel *locationIcon;

@end