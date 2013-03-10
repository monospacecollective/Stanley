//
//  SFMapCell.h
//  Stanley
//
//  Created by Eric Horacek on 3/8/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSGroupedTableViewCell.h"

@interface SFMapCell : MSGroupedTableViewCell

@property (nonatomic, strong, readonly) MKMapView *map;
@property (nonatomic, assign) MKCoordinateRegion region;

@end
