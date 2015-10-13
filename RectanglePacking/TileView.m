//
//  TileView.m
//  RectanglePacking
//
//  Created by Mariusz Graczkowski on 13.10.2015.
//  Copyright © 2015 Mariusz Graczkowski. All rights reserved.
//

#import "TileView.h"

@implementation TileView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
    }
    return self;
}
@end
