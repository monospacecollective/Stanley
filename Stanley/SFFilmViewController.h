//
//  SFFilmViewController.h
//  Stanley
//
//  Created by Eric Horacek on 3/6/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFFilm;

@interface SFFilmViewController : UICollectionViewController

@property (nonatomic, strong) SFFilm *film;

@end
