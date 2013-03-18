//
//  SFNavigationBar.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFNavigationBar.h"
#import "SFStyleManager.h"

//#define LAYOUT_DEBUG

@interface SFNavigationBar ()

@property (nonatomic, strong) UILabel *navigationPaneDirectionLabel;

+ (CGFloat)barHeight;
+ (UIFont *)titleTextFont;

- (void)updateNavigationPaneLabelForOrientation:(UIDeviceOrientation)orientation;
- (void)didChangeOrientation:(NSNotification *)notification;

@end

@implementation SFNavigationBar

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"SFHeaderBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0)];
        [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        self.titleTextAttributes = @{
            UITextAttributeFont : self.class.titleTextFont,
            UITextAttributeTextColor : [UIColor whiteColor],
            UITextAttributeTextShadowColor : [UIColor blackColor],
            UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:CGSizeMake(0.0, 2.0)]
        };
        
        self.shouldDisplayNavigationPaneDirectonLabel = NO;
        
        self.navigationPaneDirectionLabel = [UILabel new];
        self.navigationPaneDirectionLabel.text = @"\U000025BE";
        self.navigationPaneDirectionLabel.textAlignment = NSTextAlignmentCenter;
        self.navigationPaneDirectionLabel.backgroundColor = [UIColor clearColor];
        self.navigationPaneDirectionLabel.font = [[SFStyleManager sharedManager] symbolSetFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 11.0 : 9.0)];
        self.navigationPaneDirectionLabel.textColor = [UIColor whiteColor];
        self.navigationPaneDirectionLabel.shadowColor = [UIColor blackColor];
        self.navigationPaneDirectionLabel.shadowOffset = CGSizeMake(0.0, 2.0);
        self.navigationPaneDirectionLabel.userInteractionEnabled = NO;
        self.navigationPaneDirectionLabel.layer.masksToBounds = NO;
        
        self.navigationPaneDirectionLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.navigationPaneDirectionLabel.layer.shadowOffset = CGSizeZero;
        self.navigationPaneDirectionLabel.layer.shadowOpacity = 0.5;
        self.navigationPaneDirectionLabel.layer.shadowRadius = 1.0;
        
        [self addSubview:self.navigationPaneDirectionLabel];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeOrientation:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateNavigationPaneLabelForOrientation:(UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation]];
    
    for (UIView *subview in self.subviews) {
        // Hacky...
        if ([subview isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
            CGRect navigationItemFrame = subview.frame;
            navigationItemFrame.origin.y = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 13.0 : 9.0);
            navigationItemFrame.size.height = self.class.titleTextFont.lineHeight;
            subview.frame = navigationItemFrame;
            
            subview.layer.shadowColor = [[UIColor blackColor] CGColor];
            subview.layer.shadowOffset = CGSizeZero;
            subview.layer.shadowOpacity = 0.5;
            subview.layer.shadowRadius = 1.0;
            
#if defined(LAYOUT_DEBUG)
            subview.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
#endif
        }
        // If it's the right navigation button
        else if ([subview isKindOfClass:UIButton.class] && (CGRectGetMinX(subview.frame) < CGRectGetMidX(self.frame))) {
            CGRect buttonFrame = subview.frame;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                buttonFrame.origin.y = 6.0;
            }
            subview.frame = buttonFrame;
            
            [self.navigationPaneDirectionLabel sizeToFit];
            CGRect navigationPaneDirectionLabelFrame = self.navigationPaneDirectionLabel.frame;
            navigationPaneDirectionLabelFrame.origin.x = (CGRectGetMaxX(buttonFrame) - 3.0);
            navigationPaneDirectionLabelFrame.origin.y = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 22.0 : 17.0);
            self.navigationPaneDirectionLabel.frame = CGRectInset(navigationPaneDirectionLabelFrame, -2.0, -2.0);
            
            self.navigationPaneDirectionLabel.hidden = !self.shouldDisplayNavigationPaneDirectonLabel;
        }
        else if ([subview isKindOfClass:UIButton.class]) {
            CGRect buttonFrame = subview.frame;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                buttonFrame.origin.y = 6.0;
            }
            subview.frame = buttonFrame;
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake([super sizeThatFits:size].width, self.class.barHeight);
}

#pragma mark - SFNavigationBar

- (void)updateNavigationPaneLabelForOrientation:(UIDeviceOrientation)orientation
{
    if (UIDeviceOrientationIsPortrait(orientation)) {
        self.navigationPaneDirectionLabel.transform = CGAffineTransformMakeRotation(0.0);
        self.navigationPaneDirectionLabel.shadowOffset = CGSizeMake(0.0, 2.0);
    } else {
        self.navigationPaneDirectionLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.navigationPaneDirectionLabel.shadowOffset = CGSizeMake(-2.0, 0.0);
    }
}

- (void)setShouldDisplayNavigationPaneDirectonLabel:(BOOL)shouldDisplayNavigationPaneDirectonLabel
{
    _shouldDisplayNavigationPaneDirectonLabel = shouldDisplayNavigationPaneDirectonLabel;
    [self setNeedsLayout];
}

- (void)didChangeOrientation:(NSNotification *)notification
{
    UIDevice *device = [notification object];
    [self updateNavigationPaneLabelForOrientation:device.orientation];
}

+ (CGFloat)barHeight
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 56.0 : 46.0);
}

+ (UIFont *)titleTextFont
{
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 32.0 : 28.0);
    return [[SFStyleManager sharedManager] navigationFontOfSize:fontSize];
}

@end
