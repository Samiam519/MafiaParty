//
//  Player.m
//  MafiaParty
//
//  Created by Teresa Ibarra on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Player.h"

@implementation Player
{
    NSString *name;
    NSString *role;
    NSString *typeOfDeath;
    NSString *word;
    CCSprite *icon;
    Player *selectedPlayer;
    bool isDead;
    bool isSaved;
    bool hasSelected;
    
    
    bool screenTouched;
}


-(void)didLoadFromCCB
{
    hasSelected = false;
    isDead = false;
    isSaved = false;
    screenTouched = false;
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    screenTouched = true;
}

-(void)performNightAction
{
    if (role == @"citizen")
    {
        CCLOG(@"Choose a word!");
    }
    
    else if (role == "mafia")
    {
        CCLOG(@"Choose someone to kill!");
    }
    
    else if (role == "police")
    {
        CCLOG(@"Choose someone to investigate!");
    }
    
    else if (role == "doctor")
    {
        CCLOG(@"Choose someone to save!");
    }
    screenTouched = true;
}


-(void)setDead
{
    self.isDead = true;
}

-(void)savePlayer
{
    self.isSaved = true;
}

@end