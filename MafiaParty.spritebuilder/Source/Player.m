//
//  Player.m
//  MafiaParty
//
//  Created by Teresa Ibarra on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Player.h"

<<<<<<< HEAD
<<<<<<< HEAD
@implementation Player
=======
=======
>>>>>>> 4c8950ae3ea858aa43c7a934b9b9f14814524a89
@implementation Player{
    NSString *typeOfDeath;
    NSMutableArray *lynchStrings;
    NSMutableArray *murderStrings;
    NSMutableArray *saveStrings;
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
<<<<<<< HEAD
>>>>>>> f25038c6dc8ac164a6d97cde9f192e147675db80
=======
>>>>>>> 4c8950ae3ea858aa43c7a934b9b9f14814524a89

@end
