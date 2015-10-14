//
//  TileView.h
//  RectanglePacking
//
//  Created by Mariusz Graczkowski on 13.10.2015.
//  Copyright © 2015 Mariusz Graczkowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tile.h"

@interface TileView : UIView

@property(nonatomic, strong, readonly) Tile *tile;
@property(nonatomic, weak) NSLayoutConstraint *layoutWidth;
@property(nonatomic, weak) NSLayoutConstraint *layoutHeight;

- (instancetype)initWithTile:(Tile *)tile;
- (void)autosize;

@end
