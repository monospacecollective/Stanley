//
//  UIImageView+AFNetworkingCrossDisolve.h
//  Stanley
//
//  Created by Eric Horacek on 3/16/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (AFNetworkingCrossDisolve)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage fade:(BOOL)fade duration:(BOOL)duration;

@end
