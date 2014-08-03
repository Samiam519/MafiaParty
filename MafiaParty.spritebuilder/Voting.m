//
//  Voting.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Voting.h"

@implementation Voting{
    CCNode *_playerNode;
}

-(void)vote{
    CCScene *results = [CCBReader loadAsScene:@"Results"];
    [[CCDirector sharedDirector] replaceScene:results];
}

@end
