//
//  Gameplay.h
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCScene.h"

@interface Gameplay : CCScene


@property (nonatomic, strong) NSMutableArray *playerArray;


+(CCScene*)sendTheArray:(NSMutableArray*)theArray;

@end
