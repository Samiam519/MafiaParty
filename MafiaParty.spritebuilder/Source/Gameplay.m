//
//  Gameplay.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay
{
    // Loader
    CCNode *_loader;
}

- (id)init
{
    // Initialize
    self = [super init];
    
    // If intialized,
    if (self)
        // Init other players array
        _otherPlayers = [NSMutableArray array];
    return self;
}

- (void)didLoadFromCCB
{
    // Enable touches
    self.userInteractionEnabled = FALSE;
    
    // Load Role Selection scene
    CCScene *game = [CCBReader loadAsScene:@"RoleSelection" owner:self];
    [_loader addChild:game];
}

@end
