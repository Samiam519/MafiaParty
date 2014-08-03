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
    // NSString *name;
    NSString *typeOfDeath;
    NSMutableArray *lynchStrings;
    NSMutableArray *murderStrings;
    NSMutableArray *saveStrings;
    
    // CCSprite *icon;
    Player *selectedPlayer;
}

- (void)setMe:(NSString*)myName andMyPicture:(CCSprite*)myPicture
{
    // Set facebook name and picture for current user
    _FBname = myName;
    _icon = myPicture;
}

- (void)performNightAction
{
    //Add code for getting strings
}

- (void)setDead
{
    // Die
    _isDead = true;
}

- (void)savePlayer
{
    // Save
    _isSaved = true;
}

@end
