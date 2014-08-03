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
    CCLabelTTF *_MafiaGangLabel;
    
    CCTextField *_nounTextField;
    CCTextField *_verbTextField;
    CCTextField *_adjectiveTextField;
    
    CCNodeGradient *_backgroundGradient; //change color based on role
}

-(void)didLoadFromCCB
{
    player = [[Player alloc]init];
    player.hasSelected = false;
    player.isDead = false;
    player.isSaved = false;
    _nounTextField.textField.placeholder = @"test";
    
}

-(void)mafiaChat{
    
}

-(void)next{
    CCScene *results = [CCBReader loadAsScene:@"Results"];
    [[CCDirector sharedDirector] replaceScene:results];
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
