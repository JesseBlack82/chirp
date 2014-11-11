//
//  STKPlayer.h
//  Chirp
//
//  Created by Joe Conway on 11/6/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STKPlayerBullseyeKey @(25)
#define STKPlayerMissKey @(0)

@interface STKPlayer : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger score;

- (void)incrementMarkForNumber:(NSNumber *)num;
- (NSNumber *)marksForNumber:(NSNumber *)num;

- (NSDictionary *)overages;

- (void)removeOverages;

- (BOOL)isClosed;
- (BOOL)hasNumberClosed:(NSNumber *)num;

@end
