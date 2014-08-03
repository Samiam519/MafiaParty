//
//  RoleSelection.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RoleSelection.h"
#import "Player.h"

@implementation RoleSelection
{
    // Array of roles
    NSArray *_rolesArray;
    
    // Player
    Player *player;
    
    // Labels
    CCLabelTTF *_jobDescription;
    CCLabelTTF *_roleDisplay;
    CCLabelTTF *_roleLabel;
    CCLabelTTF *_RoleTaskLabel;
    CCLabelTTF *_MafiaGangLabel;
    
    
    // Text Fields
    CCTextField *_nounTextField;
    CCTextField *_verbTextField;
    CCTextField *_adjectiveTextField;
    
    // Gradient background
    CCNodeGradient *_backgroundGradient; //change color based on role
    
    CCNode *_iconNode;
    
    CGPoint touchLocation;
}

-(void)didLoadFromCCB
{
    //init playerArray
    _playerArray = [NSMutableArray array];
    
    // Init player
    player = [[Player alloc] init];
    
    // Set player booleans
    player.isDead = false;
    player.isSaved = false;
    
    // Initialize Arrays
    _rolesArray = [[NSArray alloc] init];
    self.nounArray = [[NSMutableArray alloc] init];
    self.verbArray = [[NSMutableArray alloc] init];
    self.adjectiveArray = [[NSMutableArray alloc] init];
    
    // Set text field place holders ******* FIX THIS FUCKING BULLSHIT
    _nounTextField.textField.placeholder = @"test";
    
    _nextLabel.string = @"Waiting for other players";
    _nextButton.enabled = FALSE;
    
    int i = 0;
    for (Player *player in _iconNode.children)
    {
        player.icon = ((Player *)_playerArray[i]).icon;
        i++;
    }
}

- (void)mafiaChat
{
    // Chat with other mafia people
}

- (void)next
{
    // Load Results Scene
    CCScene *results = (CCScene *)[CCBReader loadAsScene:@"Results"];
    [[CCDirector sharedDirector] replaceScene:results];
}

#pragma mark - Word Getters

- (void)getNoun
{
    // Add text to array
    [_nounArray addObject:_nounTextField.textField.text];
    
    // Send array to Firebase
    
}

- (void)getVerb
{
    // Add text to array
    [_verbArray addObject:_verbTextField.textField.text];
    
    // Send array to Firebase
    
}

- (void)getAdjective
{
    // Add text to array
    [_adjectiveArray addObject:_adjectiveTextField.textField.text];
    
    // Send array to Firebase
    
}

#pragma mark - Player methods

- (void)performNightAction: (Player*)selected
{
    [self getNoun];
    [self getAdjective];
    [self getVerb];
    
    // Perform player's night action
    if ([player.role isEqualToString:@"mafia"]) {
        [self setDead:selected];
    }
    else if ([player.role isEqualToString:@"doctor"])
    {
        [self savePlayer:selected];
    }
    else if ([player.role isEqualToString:@"police"])
    {
        [self suspectPlayer:selected];
    }
    else
    {
        [self beACitizen];
    }
}

- (void)setDead: (Player*)player
{
    // Kill player
    player.isDead = TRUE;
}

- (void)savePlayer: (Player*)player{
    // Save player
    player.isSaved = TRUE;
}

-(void)suspectPlayer: (Player *)player
{
    if ([player.role isEqualToString:@"mafia"])
    {
        CCLOG(@"%@ is mafia!", player.name);
    }
    else
    {
        CCLOG(@"%@ is not mafia!", player.name);
    }
}

-(void)beACitizen
{
    
}


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // On touch began
    touchLocation = [touch locationInWorld];
    
}

//-(void)performNightAction
//{
//    if (role == @"citizen")
//    {
//        CCLOG(@"Choose a word!");
//    }
//
//    else if (role == "mafia")
//    {
//        CCLOG(@"Choose someone to kill!");
//    }
//
//    else if (role == "police")
//    {
//        CCLOG(@"Choose someone to investigate!");
//    }
//
//    else if (role == "doctor")
//    {
//        CCLOG(@"Choose someone to save!");
//    }
//    screenTouched = true;
//}

//<<<<<<< HEAD
//
//-(void)setDead
//{
//    self.isDead = true;
//}
//
//-(void)savePlayer
//{
//    self.isSaved = true;
//}
//=======

@end
