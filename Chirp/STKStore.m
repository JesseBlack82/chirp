//
//  STKStore.m
//  Chirp
//
//  Created by Joe Conway on 11/10/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import "STKStore.h"
#import "STKGame.h"
#import "STKPlayer.h"

@implementation STKStore

+ (STKStore *)store
{
    static STKStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[STKStore alloc] init];
    });
    
    return store;
}

- (NSString *)pathForPlayerDB
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                          NSUserDomainMask,
                                                          YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"players.db"];

    return path;
}

- (void)addPlayerWithName:(NSString *)playerName
{
    NSMutableArray *a = [NSMutableArray arrayWithContentsOfFile:[self pathForPlayerDB]];
    if(!a) {
        a = [[NSMutableArray alloc] init];
    }
    [a addObject:@{@"name" : playerName, @"wins" : @(0), @"losses" : @(0)}];
    
    [a writeToFile:[self pathForPlayerDB] atomically:YES];
}

- (NSArray *)allPlayerNames
{
    NSArray *a = [NSArray arrayWithContentsOfFile:[self pathForPlayerDB]];
    if(!a) {
        return @[];
    }
    
    return [a valueForKey:@"name"];
}

- (void)updateStatisticsWithGame:(STKGame *)game
{
    NSMutableArray *a = [NSMutableArray arrayWithContentsOfFile:[self pathForPlayerDB]];
    
    STKPlayer *winner = [game winner];
    NSArray *losers = [[[game players] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name != %@", [winner name]]] valueForKey:@"name"];
    
    for(int i = 0; i < [a count]; i++) {
        NSDictionary *d = [a objectAtIndex:i];
        if([[d objectForKey:@"name"] isEqualToString:[winner name]]) {
            NSMutableDictionary *replacement = [d mutableCopy];
            [replacement setObject:@([[replacement objectForKey:@"wins"] intValue] + 1)
                            forKey:@"wins"];
            [a replaceObjectAtIndex:i withObject:replacement];
        } else if([losers containsObject:[d objectForKey:@"name"]]) {
            NSMutableDictionary *replacement = [d mutableCopy];
            [replacement setObject:@([[replacement objectForKey:@"losses"] intValue] + 1)
                            forKey:@"losses"];
            [a replaceObjectAtIndex:i withObject:replacement];
        }
    }
    
    [a writeToFile:[self pathForPlayerDB] atomically:YES];
}

@end
