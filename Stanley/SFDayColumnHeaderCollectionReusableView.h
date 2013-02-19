//
//  SFDayColumnHeaderCollectionReusableView.h
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFDayColumnHeaderCollectionReusableView : UICollectionReusableView

@property (nonatomic, strong) UILabel *day;

+ (CGSize)padding;

@end
