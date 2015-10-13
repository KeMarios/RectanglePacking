//
//  Tile.h
//  RectanglePacking
//
//  Created by Mariusz Graczkowski on 13.10.2015.
//  Copyright © 2015 Mariusz Graczkowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Unit.h"

@interface Tile : NSObject

@property(nonatomic, strong, readonly) UIColor *color;
@property(nonatomic, assign, readonly) RatioSizeTiles ratioSize;
@property(nonatomic, assign, readonly) NSNumber *remote_id;

- (instancetype)initWithRemoteID:(NSNumber *)remoteID ratioSize:(RatioSizeTiles)ratioSize;

@end
