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

<<<<<<< HEAD
    @property (nonatomic, assign) BOOL isDead;
    @property (nonatomic, assign) BOOL isSaved;
    @property (nonatomic, assign) BOOL hasSelected;
=======
@property (nonatomic,assign)  BOOL isDead;
@property (nonatomic,assign)  BOOL isSaved;
@property (nonatomic,strong)  CCSprite *icon;
@property (nonatomic,strong)  NSString *name;

-(void)setMe:(NSString*)myName andMyPicture:(CCSprite*)myPicture;

-(void)performNightAction;
>>>>>>> f25038c6dc8ac164a6d97cde9f192e147675db80



@end
