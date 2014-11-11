//
//  STKPlayerChooserViewController.m
//  Chirp
//
//  Created by Joe Conway on 11/7/14.
//  Copyright (c) 2014 stablekernel. All rights reserved.
//

#import "STKPlayerChooserViewController.h"
#import "STKPlayer.h"
#import "STKGameViewController.h"
#import "STKStore.h"

@interface STKPlayerChooserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *availablePlayerNames;
@property (nonatomic, strong) UIAlertAction *addAction;

@end

@implementation STKPlayerChooserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startGame:)];
        [bbi setEnabled:NO];
        [[self navigationItem] setRightBarButtonItem:bbi];
     
        
        _availablePlayerNames = [[STKStore store] allPlayerNames];
    }
    return self;
}

- (void)startGame:(id)sender
{
    STKGameViewController *vc = [[STKGameViewController alloc] init];
    [vc setGame:[self game]];
    
    NSMutableArray *current = [[[self navigationController] viewControllers] mutableCopy];
    UINavigationController *nvc = [self navigationController];
    [current removeLastObject];
    [current addObject:vc];
    [nvc setViewControllers:current animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    [[self tableView] reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)addPlayerWithName:(NSString *)playerName
{
    [[STKStore store] addPlayerWithName:playerName];
    _availablePlayerNames = [[STKStore store] allPlayerNames];
    
    [[self tableView] reloadData];

    [self togglePlayerAtIndex:[[self availablePlayerNames] count] - 1];

}

- (void)togglePlayerAtIndex:(NSInteger)index
{
    NSString *name = [[self availablePlayerNames] objectAtIndex:index];
    NSMutableArray *a = [[[self game] players] mutableCopy];
    if(!a)
        a = [[NSMutableArray alloc] init];
    
    NSInteger idx = NSNotFound;
    
    if([[a valueForKeyPath:@"name"] containsObject:name]) {
        idx = [a indexOfObjectPassingTest:^BOOL(STKPlayer *player, NSUInteger idx, BOOL *stop) {
            return [[player name] isEqualToString:name];
        }];
        [a removeObjectAtIndex:idx];
    } else {
        STKPlayer *p = [[STKPlayer alloc] init];
        [p setName:name];
        [a addObject:p];
        
        idx = [a count] - 1;
    }
    
    
    [[self game] setPlayers:[a copy]];
    [[self tableView] reloadData];

    if([[[self game] players] count] > 1) {
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    } else {
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if([[textField text] length] > 0) {
        [[self addAction] setEnabled:YES];
    } else {
        [[self addAction] setEnabled:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Don't select the last one
    if([indexPath row] == [tableView numberOfRowsInSection:0] - 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Add New Player"
                                                                    message:@""
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
            [textField addTarget:self
                          action:@selector(textFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
        }];
        
        [ac addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];
        
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              NSString *text = [[[ac textFields] firstObject] text];
                                                              
                                                              [self addPlayerWithName:text];
                                                          }];
        [addAction setEnabled:NO];
        [ac addAction:addAction];
        [self setAddAction:addAction];
        
        [self presentViewController:ac animated:YES completion:nil];
        
        return;
    }
    
    [self togglePlayerAtIndex:[indexPath row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self availablePlayerNames] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(!c) {
        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:@"UITableViewCell"];
    }
    
    if([indexPath row] >= [[self availablePlayerNames] count]) {
        [[c textLabel] setText:@"+ Add New Player..."];
        [c setIndentationLevel:2];
        [c setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        [c setIndentationLevel:1];

        NSString *name = [[self availablePlayerNames] objectAtIndex:[indexPath row]];
        [[c textLabel] setText:name];
        
        
        if([[[[self game] players] valueForKeyPath:@"name"] containsObject:name]) {
            [c setAccessoryType:UITableViewCellAccessoryCheckmark];

        } else {
            [c setAccessoryType:UITableViewCellAccessoryNone];

        }
    
    }
    
    return c;
}

@end
