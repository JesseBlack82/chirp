//
//  STKStore.h
//  Chirp
//
//  Created by Joe Conway on 11/10/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKGame;

@interface STKStore : NSObject

+ (STKStore *)store;

- (void)addPlayerWithName:(NSString *)playerName;
- (NSArray *)allPlayerNames;
- (void)updateStatisticsWithGame:(STKGame *)game;


@end
