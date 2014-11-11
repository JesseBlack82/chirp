//
//  STKGame.h
//  Chirp
//
//  Created by Joe Conway on 11/6/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKPlayer;
@class STKGame;

@protocol STKGameDelegate <NSObject>

- (void)game:(STKGame *)game currentPlayerDidChange:(STKPlayer *)player;
- (void)gameDidEnd:(STKGame *)game withWinner:(STKPlayer *)winner;

@end

@interface STKGame : NSObject

@property (nonatomic, strong) NSArray *players;

@property (nonatomic, assign) STKPlayer *currentPlayer;
@property (nonatomic, readonly) NSMutableArray *dartsThrownThisTurn;
@property (nonatomic, weak) id <STKGameDelegate> delegate;
@property (nonatomic) BOOL inProgress;

- (void)start;
- (void)commitTurn;
- (void)revertTurn;

- (void)submitMark:(NSNumber *)dartNumber;
- (void)submitMark:(NSNumber *)dartNumber multiplier:(NSInteger)multiplier;

- (STKPlayer *)winner;

@end
