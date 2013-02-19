//
//  SFTimeRowHeaderCollectionReusableView.h
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFTimeRowHeaderCollectionReusableView : UICollectionReusableView

@property (nonatomic, strong) UILabel *time;

+ (CGSize)padding;

@end
