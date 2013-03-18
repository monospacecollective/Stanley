//
//  UIImageView+AFNetworkingCrossDisolve.m
//  Stanley
//
//  Created by Eric Horacek on 3/16/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "UIImageView+AFNetworkingCrossDisolve.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation UIImageView (AFNetworkingCrossDisolve)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage fade:(BOOL)fade duration:(BOOL)duration
{
    NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:url];
    [imageRequest setHTTPShouldHandleCookies:NO];
    [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak typeof (self) weakSelf = self;
    [self setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (fade) {
            [UIView transitionWithView:weakSelf duration:duration options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                weakSelf.image = image;
                            } completion:nil];
        } else {
            weakSelf.image = image;
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

@end
