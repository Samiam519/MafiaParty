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
    // Player i-var
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
}

-(void)didLoadFromCCB
{
    // Init player
    player = [[Player alloc] init];
    
    // Set player booleans
    player.isDead = false;
    player.isSaved = false;
    
    // Set text field place holders ******* FIX THIS FUCKING BULLSHIT
    _nounTextField.textField.placeholder = @"test";
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



- (void)performNightAction
{
    // Perform player's night action
}

- (void)setDead
{
    // Kill player
}

- (void)savePlayer
{
    // Save player
}


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // On touch began
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
