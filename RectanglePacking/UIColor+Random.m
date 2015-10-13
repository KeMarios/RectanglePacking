//
//  UIColor+Random.m
//  RectanglePacking
//
//  Created by Mariusz Graczkowski on 13.10.2015.
//  Copyright © 2015 Mariusz Graczkowski. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor (Random)

+ (UIColor *)randomColor
{
    int red = arc4random() % 255;
    int green = arc4random() % 255;
    int blue = arc4random() % 255;
    
//    red = 10;
//    green = 10;
//    blue = 10;
    return [UIColor colorWithRed:red/ 255.0 green:green/ 255.0 blue:blue/ 255.0 alpha:1.0];
}

@end
