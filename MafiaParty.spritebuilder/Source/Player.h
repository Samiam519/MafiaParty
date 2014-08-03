//
//  Player.h
//  MafiaParty
//
//  Created by Teresa Ibarra on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Player : CCNode
    @property (nonatomic,strong) NSString *name;
    @property (nonatomic, strong) CCSprite *icon;
    @property (nonatomic, assign) NSString *role;
    @property (nonatomic, assign) NSString *typeOfDeath;
    @property (nonatomic, assign) NSString *word;

    @property (nonatomic, assign) BOOL isDead;
    @property (nonatomic, assign) BOOL isSaved;
    @property (nonatomic, assign) BOOL hasSelected;



@end
