//
//  SFLocationViewController.h
//  Stanley
//
//  Created by Eric Horacek on 3/8/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Location;

@interface SFLocationViewController : UICollectionViewController

@property (nonatomic, strong) Location *location;

@end
