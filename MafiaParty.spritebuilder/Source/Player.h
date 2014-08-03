//
//  Player.h
//  MafiaParty
//
//  Created by Teresa Ibarra on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Player : CCNode

@property (nonatomic,assign)  BOOL isDead;
@property (nonatomic,assign)  BOOL isSaved;
@property (nonatomic,strong)  CCSprite *icon;
@property (nonatomic,strong)  NSString *FBname;
@property (nonatomic,assign) BOOL hasSelected;
@property (nonatomic,assign) BOOL isHost;
@property NSString* weirdId;
-(void)setMe:(NSString*)myName andMyPicture:(CCSprite*)myPicture;

-(void)performNightAction;

-(void)setDead;

-(void)savePlayer;

@end
