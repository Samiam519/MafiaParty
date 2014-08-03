//
//  Police.m
//  MafiaParty
//
//  Created by Teresa Ibarra on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Police.h"

@implementation Police

-(void)performNightAction
{
    NSString verdict = @"not ";
    if ([self checkGuilt:selectedPlayer])
    {
        verdict = @"";
    }
    CCLOG(@"%s is %smafia", selectedPlayer.name, verdict);
}

-(bool)checkGuilt:(Player *)suspect
{
    return [suspect isKindOfClass:[Mafia class]];
}

@end
