//
//  Unit.h
//  RectanglePacking
//
//  Created by Mariusz Graczkowski on 13.10.2015.
//  Copyright © 2015 Mariusz Graczkowski. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TileTypeSmall,
    TileTypeMedium,
    TileTypeBig,
} TileType;

struct RatioSizeTiles {
    CGSize size;
    CGFloat ratio;
};
typedef struct RatioSizeTiles RatioSizeTiles;

CG_INLINE RatioSizeTiles RatioSizeTilesMake(CGSize size, CGFloat ratio);
CG_INLINE RatioSizeTiles
RatioSizeTilesMake(CGSize size, CGFloat ratio)
{
    RatioSizeTiles ratioSize; ratioSize.size = size; ratioSize.ratio = ratio; return ratioSize;
}

struct SizeTiles {
    RatioSizeTiles small;
    RatioSizeTiles medium;
    RatioSizeTiles big;
};
typedef struct SizeTiles SizeTiles;

CG_INLINE SizeTiles SizeTilesMake(RatioSizeTiles small, RatioSizeTiles medium, RatioSizeTiles big);
CG_INLINE SizeTiles
SizeTilesMake(RatioSizeTiles small, RatioSizeTiles medium, RatioSizeTiles big)
{
    SizeTiles size; size.small = small; size.medium = medium; size.big = big; return size;
}

