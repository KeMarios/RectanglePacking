//
//  NSMutableArray+MultiMutableArray.h
//  RectanglePacking
//
//  Created by Mariusz Graczkowski on 13.10.2015.
//  Copyright © 2015 Mariusz Graczkowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MultiMutableArray)

- (id)objectAtIndex:(NSUInteger)i subIndex:(NSUInteger)s;
- (void)addObject:(id)o toIndex:(NSUInteger)i;

@end
