//
//  SFFilmCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFFilmCell.h"
#import "Film.h"
#import "SFStyleManager.h"

//#define LAYOUT_DEBUG

@interface SFFilmCell ()

@property (nonatomic, strong) CAGradientLayer *backgroundGradient;

+ (CGSize)padding;
+ (UIFont *)titleFont;
+ (UIFont *)placeholderIconFont;

@end

@implementation SFFilmCell

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
        
        self.backgroundGradient = [CAGradientLayer layer];
        UIColor *overlayColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        self.backgroundGradient.colors = @[(id)[[UIColor clearColor] CGColor], (id)[overlayColor CGColor]];
        self.backgroundGradient.locations = @[@(0.7), @(0.9)];
        [self.image.layer addSublayer:self.backgroundGradient];
        
        self.favoriteIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFFilmCellFavoriteIndicator"]];
        self.favoriteIndicator.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.favoriteIndicator];
        
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
        self.placeholderIcon.textAlignment = NSTextAlignmentCenter;
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
    
    CGRect favoriteIndicatorFrame = self.favoriteIndicator.frame;
    favoriteIndicatorFrame.origin.x = (CGRectGetWidth(self.image.frame) - CGRectGetWidth(favoriteIndicatorFrame));
    self.favoriteIndicator.frame = favoriteIndicatorFrame;
    
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
    
    CGFloat minTitleLocation = (CGRectGetMinY(titleFrame) / CGRectGetHeight(self.contentView.frame));
    self.backgroundGradient.locations = @[@(minTitleLocation - 0.2), @(minTitleLocation)];
    self.backgroundGradient.frame = self.image.frame;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.image.image = nil;
    self.placeholderIcon.hidden = NO;
}

#pragma mark - SFFilmCell

- (void)setFilm:(Film *)film
{
    _film = film;
    self.title.text = [film.name uppercaseString];
    self.favoriteIndicator.hidden = ![self.film.favorite boolValue];
    
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
    CGFloat height = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 400.0 : ceilf(screenWidth * (UIInterfaceOrientationIsPortrait(orientation) ? 0.5625 : 0.375)));
    CGFloat cellWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 310.0 : (screenWidth - ([self cellSpacingForInterfaceOrientation:orientation] * 2.0)));
    return CGSizeMake(cellWidth, height);
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
