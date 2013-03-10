//
//  SFMapCell.m
//  Stanley
//
//  Created by Eric Horacek on 3/8/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFMapCell.h"

NSString* const SFMapCellPinIdentifier = @"SFMapCellPinIdentifier";
NSString* const SFMapCellCurrentLocationIdentifier = @"SFMapCellCurrentLocationIdentifier";

@interface SFMapCell () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) MKPointAnnotation *annotation;

@end

@implementation SFMapCell

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CLLocationCoordinate2DIsValid(self.region.center)) {
        [self.map setRegion:self.region animated:NO];
    }
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [[self cellPathForRect:(CGRect){CGPointZero, self.map.frame.size} cornerRadius:2.0] CGPath];
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
    
    self.annotation = [[MKPointAnnotation alloc] init];
    
    self.map = [MKMapView new];
    self.map.userInteractionEnabled = NO;
    self.map.delegate = self;
    self.map.showsUserLocation = YES;
    [self.contentView insertSubview:self.map atIndex:0];
    
    self.map.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.25] CGColor];
    self.map.layer.borderWidth = 1.0;
    
    self.backgroundView = self.map;
    
    self.selectionStyle = MSTableCellSelectionStyleNone;
    
    self.padding = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
}

+ (CGFloat)height
{
    return 200.0;
}

#pragma mark - SFMapCell

- (UIBezierPath *)cellPathForRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
    MSGroupedCellBackgroundViewType type = MSGroupedCellBackgroundViewTypeSingle;
    if ([self.superview isKindOfClass:UICollectionView.class]) {
        UICollectionView *enclosingCollectionView = (UICollectionView *)self.superview;
        NSIndexPath *indexPath = [enclosingCollectionView indexPathForCell:(UICollectionViewCell *)self];
        NSInteger rowsForSection = [enclosingCollectionView numberOfItemsInSection:indexPath.section];
        if((indexPath.row == 0) && (indexPath.row == (rowsForSection - 1))) {
            type = MSGroupedCellBackgroundViewTypeSingle;
        } else if (indexPath.row == 0) {
            type = MSGroupedCellBackgroundViewTypeTop;
        } else if (indexPath.row != (rowsForSection - 1)) {
            type = MSGroupedCellBackgroundViewTypeMiddle;
        } else {
            type = MSGroupedCellBackgroundViewTypeBottom;
        }
    }
    
    UIBezierPath *bezierPath;
    if (self.groupedCellBackgroundView.type == MSGroupedCellBackgroundViewTypeMiddle) {
        bezierPath = [UIBezierPath bezierPathWithRect:rect];
    } else {
        CGSize cornerRadii = CGSizeMake(cornerRadius , cornerRadius);
        UIRectCorner corners = 0;
        if (type == MSGroupedCellBackgroundViewTypeTop) {
            corners = (UIRectCornerTopLeft | UIRectCornerTopRight);
        } else if (type == MSGroupedCellBackgroundViewTypeBottom) {
            corners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
        } else if (type == MSGroupedCellBackgroundViewTypeSingle) {
            corners = UIRectCornerAllCorners;
        }
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:cornerRadii];
    }
    
    return bezierPath;
}

- (void)setRegion:(MKCoordinateRegion)region
{
    _region = region;
    
    self.annotation = [[MKPointAnnotation alloc] init];
    self.annotation.coordinate = self.region.center;
    
    [self.map addAnnotation:self.annotation];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:MKPointAnnotation.class]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.map dequeueReusableAnnotationViewWithIdentifier:SFMapCellPinIdentifier];
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SFMapCellPinIdentifier];
        }
        return pinView;
    }
    else if ([annotation isKindOfClass:MKUserLocation.class]) {
        SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.map dequeueReusableAnnotationViewWithIdentifier:SFMapCellCurrentLocationIdentifier];
        if(pulsingView == nil) {
            pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SFMapCellCurrentLocationIdentifier];
            pulsingView.annotationColor = [UIColor colorWithRed:0.678431 green:0 blue:0 alpha:1];
        }
        return pulsingView;
    }
    else {
        return nil;
    }
}

@end
