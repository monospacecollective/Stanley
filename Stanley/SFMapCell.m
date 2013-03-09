//
//  SFMapCell.m
//  Stanley
//
//  Created by Eric Horacek on 3/8/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFMapCell.h"

@interface SFMapCell () <MKMapViewDelegate, MKAnnotation>

@property (nonatomic, strong) MKMapView *map;

@end

@implementation SFMapCell

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CLLocationCoordinate2DIsValid(self.coordinate)) {
        [self.map setRegion:self.region animated:NO];
    }
    
    CGRect mapFrame = (CGRect){CGPointZero, self.backgroundView.frame.size};
    self.map.frame = mapFrame;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [[self cellPathForRect:mapFrame inset:CGSizeZero offset:CGSizeZero cornerRadius:self.groupedCellBackgroundView.cornerRadius] CGPath];
    self.map.layer.mask = maskLayer;
}

- (void)didMoveToSuperview
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
    });
}

#pragma mark - MSTableCell

- (void)initialize
{
    [super initialize];
    
    self.map = [MKMapView new];
    self.map.userInteractionEnabled = NO;
    self.map.delegate = self;
    self.map.showsUserLocation = YES;
    [self.map addAnnotation:self];
    [self.contentView addSubview:self.map];
    
    self.map.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.5] CGColor];
    self.map.layer.borderWidth = 1.0;
    
    self.selectionStyle = MSTableCellSelectionStyleNone;
    
    self.padding = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
}

#pragma mark - SFMapCell

- (UIBezierPath *)cellPathForRect:(CGRect)rect inset:(CGSize)insets offset:(CGSize)offset cornerRadius:(CGFloat)cornerRadius
{
    CGRect pathRect = CGRectInset(rect, insets.width, insets.height);
    UIBezierPath *bezierPath;
    if (self.groupedCellBackgroundView.type == MSGroupedCellBackgroundViewTypeMiddle) {
        bezierPath = [UIBezierPath bezierPathWithRect:pathRect];
    } else {
        CGSize cornerRadii = CGSizeMake(cornerRadius , cornerRadius);
        UIRectCorner corners;
        if (self.groupedCellBackgroundView.type == MSGroupedCellBackgroundViewTypeTop) {
            corners = (UIRectCornerTopLeft | UIRectCornerTopRight);
        } else if (self.groupedCellBackgroundView.type == MSGroupedCellBackgroundViewTypeBottom) {
            corners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
        } else if (self.groupedCellBackgroundView.type == MSGroupedCellBackgroundViewTypeSingle) {
            corners = UIRectCornerAllCorners;
        } else {
            corners = 0;
        }
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:pathRect byRoundingCorners:corners cornerRadii:cornerRadii];
    }
    [bezierPath applyTransform:CGAffineTransformMakeTranslation(offset.width, offset.height)];
    return bezierPath;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:NO];
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return self.region.center;
}

- (NSString *)title
{
    return nil;
}

- (NSString *)subtitle
{
    return nil;
}

+ (CGFloat)height
{
    return 200.0;
}

@end
