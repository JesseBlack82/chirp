//
//  STKGameViewController.m
//  Chirp
//
//  Created by Joe Conway on 11/7/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import "STKGameViewController.h"
#import "STKDartInputCell.h"
#import "STKGame.h"
#import "STKPlayer.h"
#import "STKScoreboardViewController.h"
#import "STKStore.h"

@interface STKGameViewController () <STKGameDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentPlayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstDartResult;
@property (weak, nonatomic) IBOutlet UILabel *secondDartResult;
@property (weak, nonatomic) IBOutlet UILabel *thirdDartResult;
@property (weak, nonatomic) IBOutlet UICollectionView *resultChooserView;

@property (nonatomic, weak) STKScoreboardViewController *attachedScoreboardViewController;
@property (nonatomic, strong) UIWindow *attachedWindow;

@end

@implementation STKGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Scoreboard" style:UIBarButtonItemStylePlain target:self action:@selector(showScoreboard:)];
        [[self navigationItem] setRightBarButtonItem:bbi];
        
    }
    return self;
}

- (void)setGame:(STKGame *)game
{
    _game = game;
    [game setDelegate:self];
}

- (void)game:(STKGame *)game currentPlayerDidChange:(STKPlayer *)player
{
    
}

- (void)gameDidEnd:(STKGame *)game withWinner:(STKPlayer *)winner
{
    [[STKStore store] updateStatisticsWithGame:game];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GAME OVER"
                                                                message:[NSString stringWithFormat:@"%@ won!", [winner name]]
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[self game] setInProgress:NO];
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)showScoreboard:(id)sender
{
    STKScoreboardViewController *vc = [[STKScoreboardViewController alloc] init];
    [vc setGame:[self game]];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self resultChooserView] registerNib:[UINib nibWithNibName:@"STKDartInputCell" bundle:nil]
               forCellWithReuseIdentifier:@"STKDartInputCell"];
    
    [[self resultChooserView] setBackgroundColor:[UIColor whiteColor]];

    UICollectionViewFlowLayout *l = (UICollectionViewFlowLayout *)[[self resultChooserView] collectionViewLayout];
    [l setMinimumLineSpacing:1];
    [l setMinimumInteritemSpacing:1];
    [l setSectionInset:UIEdgeInsetsZero];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![[self game] inProgress]) {
        [[self game] start];
    }
    
    [self reloadView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenConnected:)
                                                 name:UIScreenDidConnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenDisconnected:)
                                                 name:UIScreenDidDisconnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenModeChanged:)
                                                 name:UIScreenModeDidChangeNotification
                                               object:nil];
    
    if([[UIScreen screens] count] > 1) {
        [self establishOffscreenScoreboardOnScreen:[[UIScreen screens] lastObject]];
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    }
    
}


- (void)screenConnected:(NSNotification *)note
{
    UIScreen *s = [note object];
    
    [self establishOffscreenScoreboardOnScreen:s];
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
}

- (void)screenDisconnected:(NSNotification *)note
{
    [[self attachedWindow] resignKeyWindow];
    [self setAttachedWindow:nil];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

- (void)screenModeChanged:(NSNotification *)note
{
    [[self attachedWindow] resignKeyWindow];
    [self setAttachedWindow:nil];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self establishOffscreenScoreboardOnScreen:[note object]];
    }];
}

- (void)establishOffscreenScoreboardOnScreen:(UIScreen *)s
{
    STKScoreboardViewController *svc = [[STKScoreboardViewController alloc] init];
    [svc setGame:[self game]];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[s bounds]];
    [window setScreen:s];
    
    [window setRootViewController:svc];
    [window makeKeyAndVisible];
    
    [self setAttachedScoreboardViewController:svc];
    [self setAttachedWindow:window];
}


- (IBAction)confirmRound:(id)sender
{
    [[self game] commitTurn];
    [[self attachedScoreboardViewController] reload];
    [self reloadView];
}


- (IBAction)redoRoundInput:(id)sender
{
    [[self game] revertTurn];
    [self reloadView];
}

- (void)reloadView
{
    
    [[self currentPlayerLabel] setText:[[[self game] currentPlayer] name]];

    NSArray *thrownDarts = [[self game] dartsThrownThisTurn];
    
    if([thrownDarts count] == 3) {
        [[self resultChooserView] setHidden:YES];
    } else {
        [[self resultChooserView] setHidden:NO];
    }
    
    NSArray *labels = @[[self firstDartResult], [self secondDartResult], [self thirdDartResult]];
    for(UILabel *l in labels) {
        [l setText:@"_______"];
    }
    for(int i = 0; i < [thrownDarts count]; i++) {
        NSDictionary *d = [thrownDarts objectAtIndex:i];
        
        NSNumber *num = [[d allKeys] firstObject];
        NSNumber *mult = [d objectForKey:num];
        if([num isEqualToNumber:STKPlayerMissKey]) {
            [[labels objectAtIndex:i] setText:@"X"];
        } else if ([num isEqualToNumber:STKPlayerBullseyeKey]) {
            [[labels objectAtIndex:i] setText:[NSString stringWithFormat:@"%@x%@", mult, @"\u25CE"]];
        } else {
            [[labels objectAtIndex:i] setText:[NSString stringWithFormat:@"%@x%@", mult, num]];
        }
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[self resultChooserView] reloadData];

}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float w = ([[self resultChooserView] frame].size.width) / 3.0 - 1.0;
    float h = ([[self resultChooserView] frame].size.height) / 7.0;
    
    return CGSizeMake(w, h);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == [collectionView numberOfItemsInSection:0] - 1) {
        [[self game] submitMark:STKPlayerMissKey multiplier:1];
        [self reloadView];
        return;
    }
    
    NSInteger score = (6 - [indexPath row] / 3) + 14;
    NSNumber *num = @(score);
    if(score == 14) {
        num = STKPlayerBullseyeKey;
    }
    
    NSInteger multiplier = [indexPath row] % 3 + 1;
    [[self game] submitMark:num multiplier:multiplier];
    [self reloadView];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithRed:0.8 green:0.88 blue:0.9 alpha:1]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7 * 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STKDartInputCell *c = (STKDartInputCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKDartInputCell"
                                                                        forIndexPath:indexPath];

    
    if([indexPath row] == [collectionView numberOfItemsInSection:0] - 1) {
        [[c scoreLabel] setText:@"X"];
        [[c multiplierLabel] setText:@"miss"];
        return c;
    }
    
    NSInteger score = (6 - [indexPath row] / 3) + 14;
    if(score == 14) {
        [[c scoreLabel] setText:@"\u25CE"];
    } else {
        [[c scoreLabel] setText:[NSString stringWithFormat:@"%ld", score]];
    }
    
    NSInteger multiplier = [indexPath row] % 3;
    NSString *mString = nil;
    if(multiplier == 0) {
        mString = @"Single";
    } else if(multiplier == 1) {
        mString = @"Double";
    } else if(multiplier == 2) {
        mString = @"Triple";
    }
    [[c multiplierLabel] setText:mString];
    
    
    return c;
}

@end
