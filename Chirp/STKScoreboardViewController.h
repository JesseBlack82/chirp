//
//  STKScoreboardViewController.h
//  Chirp
//
//  Created by Joe Conway on 11/7/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKGame;

@interface STKScoreboardViewController : UIViewController

@property (nonatomic, weak) STKGame *game;

- (void)reload;

@end
