//
//  Tile.m
//  RectanglePacking
//
//  Created by Mariusz Graczkowski on 13.10.2015.
//  Copyright © 2015 Mariusz Graczkowski. All rights reserved.
//

#import "Tile.h"
#import "UIColor+Random.h"

@implementation Tile

- (instancetype)initWithRemoteID:(NSNumber *)remoteID ratioSize:(RatioSizeTiles)ratioSize
{
    self = [super init];
    if (self) {
        _remote_id = remoteID;
        _ratioSize = ratioSize;
        [self randomColor];
    }
    return self;
}

- (void)randomColor
{
    _color = [UIColor randomColor];
}

@end
