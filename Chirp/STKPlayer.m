//
//  STKPlayer.m
//  Chirp
//
//  Created by Joe Conway on 11/6/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import "STKPlayer.h"

@interface STKPlayer ()

@property (nonatomic, strong) NSMutableDictionary *marks;

@end

@implementation STKPlayer

- (id)init
{
    self = [super init];
    if(self) {
        _marks = [[NSMutableDictionary alloc] init];
        
        [[self marks] setObject:@(0) forKey:@(20)];
        [[self marks] setObject:@(0) forKey:@(19)];
        [[self marks] setObject:@(0) forKey:@(18)];
        [[self marks] setObject:@(0) forKey:@(17)];
        [[self marks] setObject:@(0) forKey:@(16)];
        [[self marks] setObject:@(0) forKey:@(15)];
        [[self marks] setObject:@(0) forKey:STKPlayerBullseyeKey];
    }
    return self;
}

- (BOOL)isClosed
{
    for(NSNumber *key in [self marks]) {
        NSNumber *v = [[self marks] objectForKey:key];
        
        if([v intValue] < 3)
            return NO;
    }
    
    return YES;
}

- (NSNumber *)marksForNumber:(NSNumber *)num
{
    return [[self marks] objectForKey:num];
}

- (BOOL)hasNumberClosed:(NSNumber *)num
{
    return [[[self marks] objectForKey:num] intValue] >= 3;
}

- (NSDictionary *)overages
{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    NSArray *keys = [[self marks] allKeys];
    for(NSNumber *k in keys) {
        int count = [[[self marks] objectForKey:k] intValue];
        if(count > 3) {
            NSInteger over = count - 3;
            [d setObject:@(over) forKey:k];
        }
    }
    
    return [d copy];
}

- (void)removeOverages
{
    NSArray *keys = [[self marks] allKeys];
    for(NSNumber *key in keys) {
        NSNumber *count = [[self marks] objectForKey:key];
        if([count intValue] > 3) {
            [[self marks] setObject:@(3) forKey:key];
        }
    }
}

- (void)incrementMarkForNumber:(NSNumber *)number
{
    NSNumber *currentMark = [[self marks] objectForKey:number];
    // Make sure we don't increment misses
    if(currentMark) {
        [[self marks] setObject:@([currentMark integerValue] + 1) forKey:number];
    }
}

@end
