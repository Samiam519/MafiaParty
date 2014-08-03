//
//  Player.h
//  MafiaParty
//
//  Created by Teresa Ibarra on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Player : CCNode

<<<<<<< HEAD
<<<<<<< HEAD
    @property (nonatomic, assign) BOOL isDead;
    @property (nonatomic, assign) BOOL isSaved;
    @property (nonatomic, assign) BOOL hasSelected;
=======
=======
>>>>>>> 4c8950ae3ea858aa43c7a934b9b9f14814524a89
@property (nonatomic,assign)  BOOL isDead;
@property (nonatomic,assign)  BOOL isSaved;
@property (nonatomic,strong)  CCSprite *icon;
@property (nonatomic,strong)  NSString *FBname;

-(void)setMe:(NSString*)myName andMyPicture:(CCSprite*)myPicture;

-(void)performNightAction;
<<<<<<< HEAD
>>>>>>> f25038c6dc8ac164a6d97cde9f192e147675db80
=======
>>>>>>> 4c8950ae3ea858aa43c7a934b9b9f14814524a89

-(void)setDead;

-(void)savePlayer;

@end
