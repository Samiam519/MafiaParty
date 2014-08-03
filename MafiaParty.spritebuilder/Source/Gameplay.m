//
//  Gameplay.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Player.h"


@implementation Gameplay {
    CCNode *_loader;
    Firebase *_myRootRef;
}

+(CCScene*)sendTheArray:(NSMutableArray*)theArray{
    CCScene *newScene = [CCScene node];
    [newScene addChild:[self gameplayWithArray:(NSMutableArray*)theArray]];
    return newScene;
}

+(id)gameplayWithArray:(NSMutableArray*)theArray{
    return [[self alloc]initWithAnArray:(NSMutableArray*)theArray];
}

-(id)initWithAnArray:(NSMutableArray*)theArray{
    _playerArray = [NSMutableArray array];
    
    if((self = (Gameplay *) [CCBReader load:@"Gameplay"])){
        _playerArray = theArray;
    }
    return self;
}

-(void) didLoadFromCCB {
    self.userInteractionEnabled = FALSE;
}

@end
