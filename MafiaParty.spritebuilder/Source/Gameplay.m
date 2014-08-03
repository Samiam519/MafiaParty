//
//  Gameplay.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"


@implementation Gameplay {
    CCNode *_loader;
}

-(void) didLoadFromCCB {
    CCScene *game = [CCBReader loadAsScene:@"RoleSelection" owner:self];
    [_loader addChild:game];
   
}

@end
