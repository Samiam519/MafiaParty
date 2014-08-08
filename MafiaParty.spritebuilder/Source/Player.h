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
@property (nonatomic,assign)  BOOL alreadyPicked;
@property (nonatomic,assign)  BOOL turnEnded;
@property (nonatomic,assign)  BOOL hasVoted;

// Player Image
@property (nonatomic,strong)  CCSprite *icon;

// Player Name
@property (nonatomic,strong)  NSString *FBname;

// Set role properties
@property (nonatomic,strong)  NSString *role;
@property (nonatomic,assign)  BOOL canKill;
@property (nonatomic,assign)  BOOL canSave;
@property (nonatomic,assign)  BOOL canSuspect;


@property (nonatomic, assign) int numVotes;

+(NSNumber *)sharedInstance;

// Set current player info
- (void)setMe:(NSString*)myName andMyPicture:(CCSprite*)myPicture;

// Perform the player's night action
- (void)performNightAction: (Player*)actionWithPlayer;

// Set the player to dead
- (void)setDead;

// Save the player
- (void)savePlayer;

-(void)voteForPlayer;

@end
