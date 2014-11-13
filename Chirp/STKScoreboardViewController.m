//
//  STKScoreboardViewController.m
//  Chirp
//
//  Created by Joe Conway on 11/7/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import "STKScoreboardViewController.h"
#import "STKScoreCollectionViewCell.h"
#import "STKGame.h"
#import "STKPlayer.h"

static UIImage *STKScoreboardSingleImage = nil;
static UIImage *STKScoreboardDoubleImage = nil;
static UIImage *STKScoreboardClosedImage = nil;

@interface STKScoreboardViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *scoreboardView;
@property (nonatomic, strong) NSDictionary *markToImageTransformer;

@end

@implementation STKScoreboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        
        [self loadImagesIfNecessary];
        
        _markToImageTransformer = @{
                                    @(1) : STKScoreboardSingleImage,
                                    @(2) : STKScoreboardDoubleImage,
                                    @(3) : STKScoreboardClosedImage
                                    };
                                    
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];

        [[self navigationItem] setLeftBarButtonItem:bbi];
        [[self navigationItem] setTitle:@"Scoreboard"];
    }
    return self;
}

- (void)loadImagesIfNecessary
{
    if(!STKScoreboardClosedImage) {
        CGSize imageSize = CGSizeMake(100, 100);
        CGFloat lineWidth = 4;
        
        UIGraphicsBeginImageContext(imageSize);
        
        CGFloat crossDeltaX = imageSize.width * sqrt(2) / 2;
        CGFloat crossDeltaY = crossDeltaX;
        CGPoint crossOrigin = CGPointMake( (imageSize.width - crossDeltaX) / 2,
                                          (imageSize.height - crossDeltaY) / 2);
        
        [[UIColor blackColor] set];
        
        UIBezierPath *bp = [UIBezierPath bezierPath];
        [bp moveToPoint:crossOrigin];
        [bp addLineToPoint:CGPointMake(crossOrigin.x + crossDeltaX,
                                       crossOrigin.y + crossDeltaY)];
        [bp setLineWidth:lineWidth];
        [bp stroke];
        
        STKScoreboardSingleImage = UIGraphicsGetImageFromCurrentImageContext();
        
        bp = [UIBezierPath bezierPath];
        [bp moveToPoint:CGPointMake(crossOrigin.x + crossDeltaX, crossOrigin.y)];
        [bp addLineToPoint:CGPointMake(crossOrigin.x, crossOrigin.y + crossDeltaY)];
        [bp setLineWidth:lineWidth];
        [bp stroke];
        
        STKScoreboardDoubleImage = UIGraphicsGetImageFromCurrentImageContext();
        
        
        bp = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(lineWidth / 2,
                                                               lineWidth / 2,
                                                               imageSize.width - lineWidth,
                                                               imageSize.height - lineWidth)];
        [bp setLineWidth:lineWidth];
        [bp stroke];
        
        STKScoreboardClosedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        
        UIGraphicsEndImageContext();
        
    }
}

- (void)reload
{
    [[self scoreboardView] reloadData];
}

- (void)dismiss:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self scoreboardView] reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *l = (UICollectionViewFlowLayout *)[[self scoreboardView] collectionViewLayout];
    [l setMinimumLineSpacing:0];
    [l setMinimumInteritemSpacing:0];
    [l setSectionInset:UIEdgeInsetsZero];

    [[self scoreboardView] registerNib:[UINib nibWithNibName:@"STKScoreCollectionViewCell" bundle:nil]
               forCellWithReuseIdentifier:@"STKScoreCollectionViewCell"];
    
    [[self scoreboardView] setBackgroundColor:[UIColor whiteColor]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numPlayers = [[[self game] players] count];
    float w = ([[self scoreboardView] frame].size.width) / (numPlayers + 1) - 1.0;
    float h = ([[self scoreboardView] frame].size.height - [[[self navigationController] navigationBar] bounds].size.height - [[UIApplication sharedApplication] statusBarFrame].size.height) / 9.0 - 1;
    
    return CGSizeMake(w, h);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[cell layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[cell layer] setBorderWidth:1];
    
    if([indexPath row] % ([[[self game] players] count] + 1) == 0 || [indexPath row] < [[[self game] players] count] + 1) {
        [cell setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]];
    } else {
        [cell setBackgroundColor:[UIColor colorWithRed:0.8 green:0.88 blue:0.9 alpha:1]];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9 * ([[[self game] players] count] + 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STKScoreCollectionViewCell *c = (STKScoreCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKScoreCollectionViewCell"
                                                                                                            forIndexPath:indexPath];

    [[c label] setHidden:YES];
    [[c dartImageView] setHidden:YES];
    if([indexPath row] % ([[[self game] players] count] + 1) == 0) {
        [[c label] setHidden:NO];
        
        NSInteger num = [indexPath row] / ([[[self game] players] count] + 1);
        num = 7 - num;
        if(num == 7) {
            [[c label] setText:@""];
        } else if(num == 0) {
            [[c label] setText:[NSString stringWithFormat:@"%@", @"\u25CE"]];
        } else if(num == -1) {
            [[c label] setText:@"Score"];
        } else {
            [[c label] setText:[NSString stringWithFormat:@"%ld", num + 14]];
        }
    } else {
        if([indexPath row] < [[[self game] players] count] + 1) {
            [[c label] setText:[[[[self game] players] objectAtIndex:[indexPath row] - 1] name]];
            [[c label] setHidden:NO];
        } else if([collectionView numberOfItemsInSection:0] - [indexPath row] - 1 < [[[self game] players] count]) {
            [[c label] setHidden:NO];
            NSInteger playerIndex = [indexPath row] % ([[[self game] players] count] + 1) - 1;
            [[c label] setText:[NSString stringWithFormat:@"%ld", [[[[self game] players] objectAtIndex:playerIndex] score]]];
        
        } else {
            [[c dartImageView] setHidden:NO];
            
            NSInteger playerIndex = [indexPath row] % ([[[self game] players] count] + 1) - 1;
            NSInteger num = [indexPath row] / ([[[self game] players] count] + 1);
            num = 7 - num;
            
            NSNumber *nNum = @(num + 14);
            NSLog(@"%@", nNum);
            if(num == 0) {
                nNum = STKPlayerBullseyeKey;
            }
            
            NSNumber *count = [[[[self game] players] objectAtIndex:playerIndex] marksForNumber:nNum];
         
            [[c dartImageView] setImage:[[self markToImageTransformer] objectForKey:count]];
        }
    }
    
    return c;
}

@end
