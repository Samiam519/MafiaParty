//
//  Player.m
//  MafiaParty
//
//  Created by Teresa Ibarra on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Player.h"

<<<<<<< HEAD
@implementation Player
=======
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
    _name = myName;
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
>>>>>>> f25038c6dc8ac164a6d97cde9f192e147675db80

@end
