//
//  Player.m
//  MafiaParty
//
//  Created by Teresa Ibarra on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Player.h"

@implementation Player{
//    NSString *name;
    NSString *typeOfDeath;
    NSMutableArray *lynchStrings;
    NSMutableArray *murderStrings;
    NSMutableArray *saveStrings;
//    CCSprite *icon;
    Player *selectedPlayer;

}

-(void)setMe:(NSString*)myName andMyPicture:(CCSprite*)myPicture{
    _FBname = myName;
    _icon = myPicture;
}

-(void)performNightAction
{
    //Add code for getting strings
}

-(void)setDead
{
    _isDead = true;
}

-(void)savePlayer
{
    _isSaved = true;
}

@end
