//
//  PlayerTests.m
//  Chirp
//
//  Created by Joe Conway on 11/6/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "STKPlayer.h"

@interface PlayerTests : XCTestCase

@end

@implementation PlayerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIncrementNumber
{
    STKPlayer *p = [[STKPlayer alloc] init];
    
    [p incrementMarkForNumber:@(20)];
    XCTAssert([p hasNumberClosed:@(20)] == NO);
    XCTAssert([[p marksForNumber:@(20)] intValue] == 1);

    [p incrementMarkForNumber:@(20)];
    XCTAssert([p hasNumberClosed:@(20)] == NO);
    XCTAssert([[p marksForNumber:@(20)] intValue] == 2);
    
    [p incrementMarkForNumber:@(20)];
    XCTAssert([p hasNumberClosed:@(20)] == YES);
    XCTAssert([[p marksForNumber:@(20)] intValue] == 3);
    
    [p incrementMarkForNumber:@(20)];
    XCTAssert([p hasNumberClosed:@(20)] == YES);
    NSDictionary *overages = [p overages];
    XCTAssert([[overages objectForKey:@(20)] intValue] == 1);
    XCTAssert([overages count] == 1);
    
    [p removeOverages];
    XCTAssert([p hasNumberClosed:@(20)]);
    overages = [p overages];
    XCTAssert([overages count] == 0);
    XCTAssert([[p marksForNumber:@(20)] intValue] == 3);
}

- (void)testMultipleOverages
{
    STKPlayer *p = [[STKPlayer alloc] init];
    
    for(int i = 0; i < 5; i++) {
        [p incrementMarkForNumber:@(19)];
        [p incrementMarkForNumber:STKPlayerBullseyeKey];
    }
    
    XCTAssert([p hasNumberClosed:@(19)] == YES);
    XCTAssert([p hasNumberClosed:STKPlayerBullseyeKey] == YES);
    
    NSDictionary *overages = [p overages];
    XCTAssert([[overages objectForKey:@(19)] intValue] == 2);
    XCTAssert([[overages objectForKey:STKPlayerBullseyeKey] intValue] == 2);
    
    [p removeOverages];
    
    XCTAssert([p hasNumberClosed:@(19)] == YES);
    XCTAssert([p hasNumberClosed:STKPlayerBullseyeKey] == YES);
    XCTAssert([[p overages] count] == 0);
}

- (void)testAllClosed
{
    STKPlayer *p = [[STKPlayer alloc] init];
    
    for(int i = 0; i < 3; i++) {
        [p incrementMarkForNumber:@(20)];
        [p incrementMarkForNumber:@(19)];
        [p incrementMarkForNumber:@(18)];
        [p incrementMarkForNumber:@(17)];
        [p incrementMarkForNumber:@(16)];
        [p incrementMarkForNumber:@(15)];
        [p incrementMarkForNumber:STKPlayerBullseyeKey];
    }
    XCTAssert([p isClosed]);

}

@end
