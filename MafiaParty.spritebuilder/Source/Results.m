//
//  Results.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Results.h"

@implementation Results{
    CCLabelTTF *_storyLabel;
    CCLabelTTF *nextLabel;
}

-(void)next{
    //if mafia caught -> play again goes to lobby
    CCScene *lobby = [CCBReader loadAsScene:@"Lobby"];
    [[CCDirector sharedDirector] replaceScene:lobby];
    //if mafia not caught -> role selection
    CCScene *roleScreen = [CCBReader loadAsScene:@"RoleSelection"];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

@end
