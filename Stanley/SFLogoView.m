//
//  SFLogoView.m
//  Stanley
//
//  Created by Eric Horacek on 2/17/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFLogoView.h"
#import "SFStyleManager.h"

//#define LAYOUT_DEBUG

@interface SFLogoView ()

@property (nonatomic, strong) UILabel *filmLabel;
@property (nonatomic, strong) UILabel *festivalLabel;
@property (nonatomic, strong) UILabel *stanleyLabel;

- (CGFloat)subtextMargin;

@end

@implementation SFLogoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.filmLabel = [UILabel new];
        self.festivalLabel = [UILabel new];
        self.stanleyLabel = [UILabel new];
        
        self.filmLabel.text = @"F I L M";
        self.festivalLabel.text = @"F E S T I V A L";
        self.stanleyLabel.text = @"S T A N L E Y";
        
        self.filmLabel.backgroundColor = [UIColor clearColor];
        self.festivalLabel.backgroundColor = [UIColor clearColor];
        self.stanleyLabel.backgroundColor = [UIColor clearColor];
        
        self.filmLabel.textColor = [UIColor whiteColor];
        self.festivalLabel.textColor = [UIColor whiteColor];
        self.stanleyLabel.textColor = [UIColor whiteColor];
        
        self.stanleyFontSize = 40.0;
        
        [self addSubview:self.filmLabel];
        [self addSubview:self.festivalLabel];
        [self addSubview:self.stanleyLabel];
        
#if defined(LAYOUT_DEBUG)
        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
        self.filmLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.festivalLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.stanleyLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
#endif
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.filmLabel sizeToFit];
    CGRect filmLabelFrame = self.filmLabel.frame;
    filmLabelFrame.origin.x = floorf((CGRectGetWidth(self.frame) / 2.0) - (CGRectGetWidth(filmLabelFrame) / 2.0));
    self.filmLabel.frame = filmLabelFrame;
    
    [self.stanleyLabel sizeToFit];
    CGRect stanleyLabelFrame = self.stanleyLabel.frame;
    stanleyLabelFrame.origin.y = (CGRectGetMaxY(filmLabelFrame) + self.subtextMargin);
    stanleyLabelFrame.origin.x = floorf((CGRectGetWidth(self.frame) / 2.0) - (CGRectGetWidth(stanleyLabelFrame) / 2.0));
    self.stanleyLabel.frame = stanleyLabelFrame;
    
    [self.festivalLabel sizeToFit];
    CGRect festivalLabelFrame = self.festivalLabel.frame;
    festivalLabelFrame.origin.y = (CGRectGetMaxY(stanleyLabelFrame) + self.subtextMargin - (self.festivalLabel.font.lineHeight * 0.2));
    festivalLabelFrame.origin.x = floorf((CGRectGetWidth(self.frame) / 2.0) - (CGRectGetWidth(festivalLabelFrame) / 2.0));
    self.festivalLabel.frame = festivalLabelFrame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize stanleyLabelSize = [self.stanleyLabel.text sizeWithFont:self.stanleyLabel.font];
    CGFloat width = stanleyLabelSize.width;
    
    CGFloat filmLabelHeight = [self.filmLabel.text sizeWithFont:self.filmLabel.font].height;
    CGFloat festivalLabelHeight = [self.festivalLabel.text sizeWithFont:self.festivalLabel.font].height;
    CGFloat height = (filmLabelHeight + self.subtextMargin + stanleyLabelSize.height + (self.subtextMargin - (self.festivalLabel.font.lineHeight * 0.2)) + festivalLabelHeight);
    
    return CGSizeMake(width, height);
}

#pragma mark - SFLogoView

- (void)setStanleyFontSize:(CGFloat)stanleyFontSize
{
    _stanleyFontSize = stanleyFontSize;
    CGFloat subtextFontSize = (stanleyFontSize * 0.5);
    
    self.filmLabel.font = [[SFStyleManager sharedManager] titleFontOfSize:subtextFontSize];
    self.festivalLabel.font = [[SFStyleManager sharedManager] titleFontOfSize:subtextFontSize];
    self.stanleyLabel.font = [[SFStyleManager sharedManager] titleFontOfSize:stanleyFontSize];
    
    [self setNeedsLayout];
}

- (CGFloat)subtextMargin
{
    return (_stanleyFontSize / 2.5);
}

@end
