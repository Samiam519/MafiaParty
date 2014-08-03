//
//  Player.h
//  MafiaParty
//
//  Created by Teresa Ibarra on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Player : CCNode

// Public Booleans
@property (nonatomic,assign)  BOOL isDead;
@property (nonatomic,assign)  BOOL isSaved;

// Player Image
@property (nonatomic,strong)  CCSprite *icon;

// Player Name
@property (nonatomic,strong)  NSString *FBname;

// Set current player info
- (void)setMe:(NSString*)myName andMyPicture:(CCSprite*)myPicture;

// Perform the player's night action
- (void)performNightAction;

// Set the player to dead
- (void)setDead;

// Save the player
- (void)savePlayer;

@end
