//
//  Voting.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "VoteScreen.h"
#import "Player.h"

@implementation VoteScreen
{
    // Player node
    CCNode *_playerNode;
    
    CCNode *_iconNode;
    
    CGPoint touchLocation;
    
    CCButton *_voteButton;
    
    CCLabelTTF *_voteLabel;
    
}

-(void)didLoadFromCCB
{
    self.userInteractionEnabled = true;
    _voteButton.enabled = FALSE;
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    touchLocation = [touch locationInWorld];
}

-(void)update:(CCTime)delta
{
    for (Player *curPlayer in _iconNode.children)
    {
        if (CGRectContainsPoint(curPlayer.boundingBox, touchLocation))
        {
            [curPlayer voteForPlayer];
        }
    }
    
    for (Player *currentPlayer in _iconNode.children)
    {
        if (!currentPlayer.hasVoted)
        {
            return;
        }
    }
    Player *lynched = [self tallyVotes];
    [lynched setDead];
    _voteButton.enabled = true;
    _voteLabel.string = @"Results";
    
    
}

-(Player *)tallyVotes
{
    Player *highest;
    highest.numVotes = 0;
    for (Player *curPlayer in _iconNode.children)
    {
        if (curPlayer.numVotes > highest.numVotes)
        {
            highest = curPlayer;
        }
    }
    return highest;
}

- (void)vote
{
    // Go to Results Scene
    CCScene *results = (CCScene *)[CCBReader loadAsScene:@"Results"];
    [[CCDirector sharedDirector] replaceScene:results];
}

@end
