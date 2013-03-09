//
//  SFEventViewController.h
//  Stanley
//
//  Created by Eric Horacek on 3/9/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface SFEventViewController : UICollectionViewController

@property (nonatomic, weak) Event *event;

@end
