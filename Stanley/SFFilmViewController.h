//
//  SFFilmViewController.h
//  Stanley
//
//  Created by Eric Horacek on 3/6/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Film;

@interface SFFilmViewController : UICollectionViewController

@property (nonatomic, strong) Film *film;

@end
