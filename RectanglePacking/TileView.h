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

- (instancetype)initWithTile:(Tile *)tile;

@end
