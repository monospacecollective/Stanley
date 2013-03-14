//
//  SFSocialViewController.h
//  Stanley
//
//  Created by Devon Tivona on 3/13/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSSocialKitViewController.h"

@interface SFSocialViewController : UIViewController

@property (strong, nonatomic) SVSegmentedControl *segmentedControl;
@property (strong, nonatomic) UIViewController <MSSocialChildViewController> *currentChildViewController;
@property (strong, nonatomic) UIView *containerView;

@end
