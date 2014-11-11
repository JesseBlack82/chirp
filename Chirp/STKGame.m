//
//  STKGame.m
//  Chirp
//
//  Created by Joe Conway on 11/6/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import "STKGame.h"
#import "STKPlayer.h"


@implementation STKGame

- (void)start
{
    _inProgress = YES;
    _dartsThrownThisTurn = [[NSMutableArray alloc] init];
    [self setCurrentPlayer:[[self players] firstObject]];
}

- (void)setCurrentPlayer:(STKPlayer *)currentPlayer
{
    _currentPlayer = currentPlayer;
    [[self dartsThrownThisTurn] removeAllObjects];
    [[self delegate] game:self currentPlayerDidChange:currentPlayer];
}

- (void)submitMark:(NSNumber *)dartNumber
{
    [self submitMark:dartNumber multiplier:1];
}

- (void)submitMark:(NSNumber *)dartNumber multiplier:(NSInteger)multiplier
{
    if([[self dartsThrownThisTurn] count] == 3) {
        return;
    }
    
    [[self dartsThrownThisTurn] addObject:@{dartNumber : @(multiplier)}];
}

- (void)revertTurn
{
    [[self dartsThrownThisTurn] removeAllObjects];
}

- (void)commitTurn
{
    for(NSDictionary *dart in [self dartsThrownThisTurn]) {
        NSNumber *dartNumber = [[dart allKeys] firstObject];
        NSInteger multiplier = [[dart objectForKey:dartNumber] integerValue];
        for(int i = 0; i < multiplier; i++) {
            [[self currentPlayer] incrementMarkForNumber:dartNumber];
        }
    }
    
    NSDictionary *overages = [[self currentPlayer] overages];
    
    if([overages count] > 0) {
        for(STKPlayer *p in [self players]) {
            if(p != [self currentPlayer]) {
                for(NSNumber *numberKey in overages) {
                    if(![p hasNumberClosed:numberKey]) {
                        NSInteger pScore = [p score];
                        pScore += [numberKey integerValue] * [[overages objectForKey:numberKey] integerValue];
                        [p setScore:pScore];
                    }
                }
            }
        }
    }
    
    [[self currentPlayer] removeOverages];
    
    STKPlayer *winner = [self winner];
    if(winner) {
        [[self delegate] gameDidEnd:self withWinner:winner];
    } 
    
    NSInteger playerIndex = [[self players] indexOfObject:[self currentPlayer]];
    playerIndex = (playerIndex + 1) % [[self players] count];
    
    [self setCurrentPlayer:[[self players] objectAtIndex:playerIndex]];
}

- (STKPlayer *)winner
{
    for(STKPlayer *p in [self players]) {
        if([p isClosed]) {
            BOOL hasLeastAmountOfPoints = YES;
            for(STKPlayer *otherPlayer in [self players]) {
                if(p == otherPlayer)
                    continue;
                
                if([otherPlayer score] < [p score]) {
                    hasLeastAmountOfPoints = NO;
                }
            }
            if(hasLeastAmountOfPoints)
                return p;
        }
    }
    return nil;
}


@end
