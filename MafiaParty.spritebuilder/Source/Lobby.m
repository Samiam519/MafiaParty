//
//  Lobby.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Lobby.h"

@implementation Lobby{
    CCLabelTTF *_playersReadyLabel;
    CCLabelTTF *_mafiaPlayersLabel;
}

-(void)unlockRoles{
    CCScene *store = [CCBReader loadAsScene:@"Store"];
    [[CCDirector sharedDirector] pushScene:store];
}

-(void)play{
    CCScene *roleScreen = [CCBReader loadAsScene:@"RoleSelection"];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

-(void)ghettoPlay{
    CCScene *roleScreen = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

@end
