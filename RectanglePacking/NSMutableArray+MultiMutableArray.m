//
//  NSMutableArray+MultiMutableArray.m
//  RectanglePacking
//
//  Created by Mariusz Graczkowski on 13.10.2015.
//  Copyright © 2015 Mariusz Graczkowski. All rights reserved.
//

#import "NSMutableArray+MultiMutableArray.h"

@implementation NSMutableArray (MultiMutableArray)

- (id)objectAtIndex:(NSUInteger)i subIndex:(NSUInteger)s
{    id subArray = [self objectAtIndex:i];
    return [subArray isKindOfClass:NSArray.class] ? [subArray objectAtIndex:s] : nil;
}

- (void)addObject:(id)o toIndex:(NSUInteger)i
{
    while(self.count <= i)
        [self addObject:NSMutableArray.new];
    NSMutableArray* subArray = [self objectAtIndex:i];
    [subArray addObject: o];
}

@end
