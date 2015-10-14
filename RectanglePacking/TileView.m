//
//  TileView.m
//  RectanglePacking
//
//  Created by Mariusz Graczkowski on 13.10.2015.
//  Copyright © 2015 Mariusz Graczkowski. All rights reserved.
//

#import "TileView.h"

@interface TileView ()

@property(nonatomic, weak) UILabel *titleLabel;

@end

@implementation TileView

- (instancetype)initWithTile:(Tile *)tile
{
    self = [super init];
    if (self) {
        _tile = tile;
        self.backgroundColor = _tile.color;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
        [self setup];
    }
    return self;
}

- (void)setup
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel = titleLabel;
    self.titleLabel.tintColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.titleLabel];
    titleLabel.text = [NSString stringWithFormat:@"%@", self.tile.remote_id];
}

- (void)autosize
{
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[titleLabel]-0-|"
                                             options:0 metrics:nil
                                               views:@{@"titleLabel":self.titleLabel}]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[titleLabel]-0-|"
                                             options:0 metrics:nil
                                               views:@{@"titleLabel":self.titleLabel}]];
}

@end
