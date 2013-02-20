//
//  SFFilmCollectionViewCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFFilmCollectionViewCell.h"
#import "Film.h"
#import "SFStyleManager.h"

//#define LAYOUT_DEBUG

@interface SFFilmCollectionViewCell ()

+ (CGSize)padding;
+ (UIFont *)titleFont;
+ (UIFont *)placeholderIconFont;

@end

@implementation SFFilmCollectionViewCell

#pragma mark - UICollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        self.contentView.backgroundColor = [[SFStyleManager sharedManager] secondaryViewBackgroundColor];
        
        self.image = [UIImageView new];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.layer.masksToBounds = YES;
        self.image.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.image];
        
        self.placeholderIcon = [FXLabel new];
        self.placeholderIcon.font = self.class.placeholderIconFont;
        self.placeholderIcon.text = @"\U0000E320";
        self.placeholderIcon.textColor = [UIColor colorWithHexString:@"222222"];
        self.placeholderIcon.backgroundColor = [UIColor clearColor];
        self.placeholderIcon.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        self.placeholderIcon.shadowOffset = CGSizeMake(0.0, 1.0);
        self.placeholderIcon.shadowBlur = 0.0;
        self.placeholderIcon.innerShadowColor = [UIColor colorWithHexString:@"101010"];
        self.placeholderIcon.innerShadowOffset = CGSizeMake(0.0, 2.0);
        self.placeholderIcon.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:self.placeholderIcon];
        
        self.title = [UILabel new];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textColor = [UIColor whiteColor];
        self.title.font = self.class.titleFont;
        self.title.numberOfLines = 0;
        self.title.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.title.layer.shadowRadius = 2.0;
        self.title.layer.shadowOpacity = 1.0;
        self.title.layer.shadowOffset = CGSizeZero;
        self.title.layer.masksToBounds = NO;
        [self.contentView addSubview:self.title];
        
        self.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor];
        self.layer.borderWidth = 1.0;
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 0.0;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSizeZero;
        
        self.contentView.layer.masksToBounds = NO;
        self.contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.contentView.layer.shadowRadius = 3.0;
        self.contentView.layer.shadowOpacity = 0.5;
        self.contentView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        
#if defined(LAYOUT_DEBUG)
        self.title.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.placeholderIcon.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
#endif
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.contentView.frame, -2.0, -2.0)] CGPath];
    self.contentView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.contentView.frame, -2.0, -2.0)] CGPath];
    
    self.image.frame = self.contentView.frame;
    
    CGSize padding = self.class.padding;
    
    CGSize maxContentSize = CGRectInset(self.contentView.frame, padding.width, padding.height).size;
    
    CGSize placeholderSize = [self.placeholderIcon.text sizeWithFont:self.placeholderIcon.font constrainedToSize:maxContentSize];
    CGRect placeholderIconFrame = self.placeholderIcon.frame;
    placeholderIconFrame.size = placeholderSize;
    placeholderIconFrame.origin.x = floorf((CGRectGetWidth(self.contentView.frame) / 2.0) - (CGRectGetWidth(placeholderIconFrame) / 2.0));
    placeholderIconFrame.origin.y = floorf((CGRectGetHeight(self.contentView.frame) / 2.0) - (CGRectGetHeight(placeholderIconFrame) / 2.0)) + ceilf(self.placeholderIcon.font.lineHeight * 0.09);
    self.placeholderIcon.frame = placeholderIconFrame;
    
    CGSize titleSize = [self.title.text sizeWithFont:self.title.font constrainedToSize:maxContentSize lineBreakMode:self.title.lineBreakMode];
    CGRect titleFrame = self.title.frame;
    titleFrame.size = titleSize;
    titleFrame.origin.x = padding.width;
    // Add a third of the line height so that the baseline is the true bottom of the frame
    titleFrame.origin.y = CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(titleFrame) - padding.height + ceilf(self.title.font.lineHeight * 0.3);
    self.title.frame = titleFrame;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.image.image = nil;
    self.placeholderIcon.hidden = NO;
}

#pragma mark - SFFilmCollectionViewCell

- (void)setFilm:(Film *)film
{
    _film = film;
    self.title.text = [film.name uppercaseString];
    
    NSURL *imageURL = [NSURL URLWithString:film.featureImage];
    NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:imageURL];
    [imageRequest setHTTPShouldHandleCookies:NO];
    [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak typeof(self) weakSelf = self;
    [self.image setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.image.image = image;
        weakSelf.placeholderIcon.hidden = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.placeholderIcon.hidden = NO;
    }];
    
    [self setNeedsLayout];
}

+ (CGSize)padding
{
    return CGSizeMake(15.0, 15.0);
}

+ (UIFont *)titleFont
{
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 25.0 : 23.0);
    return [[SFStyleManager sharedManager] titleFontOfSize:fontSize];
}

+ (UIFont *)placeholderIconFont
{
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 200.0 : 130.0);
    return [[SFStyleManager sharedManager] symbolSetFontOfSize:fontSize];
}

+ (CGSize)cellSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation;
{
    CGFloat screenWidth = (UIInterfaceOrientationIsPortrait(orientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height);
    CGFloat cellHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 400.0 : ceilf(screenWidth * (UIInterfaceOrientationIsPortrait(orientation) ? 0.5625 : 0.375)));
    CGFloat cellWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 310.0 : (screenWidth - ([self cellSpacingForInterfaceOrientation:orientation] * 2.0)));
    return CGSizeMake(cellWidth, cellHeight);
}

+ (UIEdgeInsets)cellMarginForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat spacingSize = [self cellSpacingForInterfaceOrientation:orientation];
    return UIEdgeInsetsMake(spacingSize, spacingSize, spacingSize, spacingSize);
}

+ (CGFloat)cellSpacingForInterfaceOrientation:(UIInterfaceOrientation)orientation;
{
    CGFloat spacingSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (UIInterfaceOrientationIsPortrait(orientation) ? 49.0 : 23.0) : (UIInterfaceOrientationIsPortrait(orientation) ? 10.0 : 15.0));
    return spacingSize;
}

@end
