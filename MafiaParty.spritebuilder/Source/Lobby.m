//
//  Lobby.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Lobby.h"

@implementation Lobby
{
    // Labels
    CCLabelTTF *_playersReadyLabel;
    CCLabelTTF *_mafiaPlayersLabel;
}

- (void)unlockRoles
{
    // Load the Store
    CCScene *store = (CCScene *)[CCBReader loadAsScene:@"Store"];
    [[CCDirector sharedDirector] pushScene:store];
}

- (void)play
{
    // Load Role Selection
    CCScene *roleScreen = (CCScene *)[CCBReader loadAsScene:@"RoleSelection"];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

- (void)ghettoPlay
{
    // GHETTOOOOOOOOOOO
    CCScene *roleScreen = (CCScene *)[CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

@end
