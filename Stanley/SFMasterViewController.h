//
//  SFMasterViewController.h
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SFPaneType) {
    SFPaneTypeFilms,
    SFPaneTypeNews,
    SFPaneTypeEvents,
    SFPaneTypeMap,
    SFPaneTypeCommunity,
    SFPaneTypeCount
};

@interface SFMasterViewController : UITableViewController

@property (nonatomic, assign) SFPaneType paneType;
@property (nonatomic, weak) MSNavigationPaneViewController *navigationPaneViewController;

- (void)transitionToPane:(SFPaneType)paneType;

@end
