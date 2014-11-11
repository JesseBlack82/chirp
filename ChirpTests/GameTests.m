//
//  GameTests.m
//  Chirp
//
//  Created by Joe Conway on 11/7/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "STKGame.h"
#import "STKPlayer.h"

@interface GameTests : XCTestCase

@end

@implementation GameTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (STKGame *)startedGameWithPlayerCount:(int)count
{
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for(int i = 0; i < count; i++) {
        STKPlayer *p = [[STKPlayer alloc] init];
        [p setName:[NSString stringWithFormat:@"Player %d", i]];
        [a addObject:p];
    }
    
    STKGame *g = [[STKGame alloc] init];
    [g setPlayers:[a copy]];
    [g start];

    return g;
}

- (void)testStart
{
    NSArray *players = @[[[STKPlayer alloc] init], [[STKPlayer alloc] init], [[STKPlayer alloc] init]];
    STKGame *g = [[STKGame alloc] init];
    [g setPlayers:players];
    
    [g start];
    
    XCTAssert([g currentPlayer] != nil);
    XCTAssert([[g dartsThrownThisTurn] count] == 0);
}

- (void)testSubmitMarks
{
    STKGame *g = [self startedGameWithPlayerCount:2];
    
    STKPlayer *p = [g currentPlayer];
    
    [g submitMark:@(20)];
    [g submitMark:@(19)];
    [g submitMark:@(20) multiplier:3];
    [g commitTurn];
    
    XCTAssert([p hasNumberClosed:@(20)] == YES);
    XCTAssert([p hasNumberClosed:@(19)] == NO);
    XCTAssert([[p marksForNumber:@(20)] isEqualToNumber:@3]);
    XCTAssert([[p marksForNumber:@(19)] isEqualToNumber:@1]);
    XCTAssert([p score] == 0);
    
    XCTAssert([[g currentPlayer] score] == 20);
    XCTAssert(p != [g currentPlayer]);
    XCTAssert([g winner] == nil);
    
}

- (void)testScoring
{
    STKGame *g = [self startedGameWithPlayerCount:2];
    
    STKPlayer *p = [g currentPlayer];
    [g submitMark:@(20)];
    [g submitMark:@(20)];
    [g submitMark:@(20)];
    [g commitTurn];
    
    STKPlayer *nextPlayer = [g currentPlayer];
    XCTAssert(nextPlayer != p);
    [g submitMark:@(20)];
    [g submitMark:@(20)];
    [g submitMark:@(20) multiplier:2];
    [g commitTurn];

    XCTAssert([p score] == 0);
    XCTAssert([nextPlayer score] == 0);
    XCTAssert([p hasNumberClosed:@(20)] == YES);
    XCTAssert([nextPlayer hasNumberClosed:@(20)] == YES);
}

- (void)testWinner
{
    STKGame *g = [self startedGameWithPlayerCount:2];
    
    STKPlayer *p = [g currentPlayer];
    
    for(int i = 0; i < 3; i++) {
        [p incrementMarkForNumber:@(20)];
        [p incrementMarkForNumber:@(19)];
        [p incrementMarkForNumber:@(18)];
        [p incrementMarkForNumber:@(17)];
        [p incrementMarkForNumber:@(16)];
        [p incrementMarkForNumber:@(15)];
        [p incrementMarkForNumber:STKPlayerBullseyeKey];
    }
    
    XCTAssert([g winner] == p);
    
    [p setScore:20];
    XCTAssert([g winner] == nil);
}

- (void)testWinnerBothClosed
{
    STKGame *g = [self startedGameWithPlayerCount:2];
    
    for(STKPlayer *p in [g players]) {
        for(int i = 0; i < 3; i++) {
            [p incrementMarkForNumber:@(20)];
            [p incrementMarkForNumber:@(19)];
            [p incrementMarkForNumber:@(18)];
            [p incrementMarkForNumber:@(17)];
            [p incrementMarkForNumber:@(16)];
            [p incrementMarkForNumber:@(15)];
            [p incrementMarkForNumber:STKPlayerBullseyeKey];
        }
    }
    [[g currentPlayer] setScore:20];
    
    XCTAssert([g winner] != [g currentPlayer]);
    XCTAssert([g winner] != nil);
}

@end
