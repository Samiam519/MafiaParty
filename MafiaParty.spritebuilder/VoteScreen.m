//
//  Voting.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "VoteScreen.h"

@implementation VoteScreen
{
    // Player node
    CCNode *_playerNode;
}

-(void)didLoadFromCCB
{
    self.userInteractionEnabled = true;

}

- (void)vote
{
    // Go to Results Scene
    CCScene *results = (CCScene *)[CCBReader loadAsScene:@"Results"];
    [[CCDirector sharedDirector] replaceScene:results];
}

@end
