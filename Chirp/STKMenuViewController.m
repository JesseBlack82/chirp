//
//  STKMenuViewController.m
//  Chirp
//
//  Created by Joe Conway on 11/7/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import "STKMenuViewController.h"
#import "STKGame.h"
#import "STKGameViewController.h"
#import "STKPlayerChooserViewController.h"

@interface STKMenuViewController ()

@property (weak, nonatomic) IBOutlet UIButton *resumeGameButton;
@property (nonatomic, strong) STKGame *currentGame;
@end

@implementation STKMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![[self currentGame] inProgress]) {
        [self setCurrentGame:nil];
    }
    
    [[self resumeGameButton] setHidden:[self currentGame] == nil];
}

- (IBAction)newGame:(id)sender
{
    STKGame *g = [[STKGame alloc] init];
    [self setCurrentGame:g];
    
    STKPlayerChooserViewController *pvc = [[STKPlayerChooserViewController alloc] init];
    [pvc setGame:[self currentGame]];

    [[self navigationController] pushViewController:pvc
                                           animated:YES];
}

- (IBAction)resumeGame:(id)sender
{
    STKGameViewController *gvc = [[STKGameViewController alloc] init];
    [gvc setGame:[self currentGame]];
    [[self navigationController] pushViewController:gvc
                                           animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
