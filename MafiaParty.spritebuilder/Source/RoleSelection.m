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
    Player *player;
    CCLabelTTF *_jobDescription;
    CCLabelTTF *_roleDisplay;
    
    CCNode *_mafiaNode;
    CCNode *_playerNode;
    CCLabelTTF *_roleLabel;
    CCLabelTTF *_RoleTaskLabel;
    
    CCTextField *_noun1TextField;
    CCTextField *_noun2TextField;
    CCTextField *_verb1TextField;
    CCTextField *_verb2TextField;
    CCTextField *_adjective1TextField;
    CCTextField *_adjective2TextField;
    
    CCNodeGradient *_backgroundGradient; //change color based on role
}

-(void)mafiaChat{
    
}

-(void)next{
    CCScene *results = [CCBReader loadAsScene:@"Results"];
    [[CCDirector sharedDirector] replaceScene:results];
}

-(void)didLoadFromCCB
{
    player = [[Player alloc]init];
    player.hasSelected = false;
    player.isDead = false;
    player.isSaved = false;
    
}

-(void)performNightAction {
    
}

-(void)setDead {
    
}

-(void)savePlayer{
    
}


-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    
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
