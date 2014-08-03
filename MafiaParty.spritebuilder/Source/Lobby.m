//
//  Lobby.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Lobby.h"
#import "Gameplay.h"

@implementation Lobby{
    CCLabelTTF *_playersReadyLabel;
    CCLabelTTF *_mafiaPlayersLabel;
    CCNode *_playersNode;
    Firebase *lobbyRef;
}

-(void)didLoadFromCCB{
    lobbyRef = [[Firebase alloc] initWithUrl:@"https://mafiagame.firebaseio.com/games"];
    _otherPlayers = [NSMutableArray array];
    [lobbyRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
            Player *newPlayer = [[Player alloc] init];
            CCSprite *newImage;
            newImage = [[CCSprite alloc]init];
            NSString *_tempImagez = snapshot.value[@"Picture URL"];
            NSURL *url = [NSURL URLWithString:_tempImagez];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            
            //convert UIImage to CCSprite
            CCTexture *texture = [[CCTexture alloc]initWithCGImage:image.CGImage contentScale:1.f];
            newImage.spriteFrame = [CCSpriteFrame frameWithTexture:texture rectInPixels:CGRectMake(0.f, 0.f, 100.f, 100.f) rotated:NO offset:ccp(0,0) originalSize:CGSizeMake(1.f, 1.f)];
            [newPlayer setMe:snapshot.value[@"Name"] andMyPicture:newImage];
            [_otherPlayers addObject:newPlayer];
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    [lobbyRef observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        Player *newPlayer = [[Player alloc] init];
        CCSprite *newImage;
        newImage = [[CCSprite alloc]init];
        NSString *_tempImagez = snapshot.value[@"Picture URL"];
        NSURL *url = [NSURL URLWithString:_tempImagez];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        //convert UIImage to CCSprite
        CCTexture *texture = [[CCTexture alloc]initWithCGImage:image.CGImage contentScale:1.f];
        newImage.spriteFrame = [CCSpriteFrame frameWithTexture:texture rectInPixels:CGRectMake(0.f, 0.f, 100.f, 100.f) rotated:NO offset:ccp(0,0) originalSize:CGSizeMake(1.f, 1.f)];
        [newPlayer setMe:snapshot.value[@"Name"] andMyPicture:newImage];
        [_otherPlayers addObject:newPlayer];
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
}

-(void)update:(CCTime)delta{
    
    _playersReadyLabel.string = [NSString stringWithFormat:@"%d", (int)[_otherPlayers count]];
}

-(void)onEnter{
    [super onEnter];
    _playersReadyLabel.string = [NSString stringWithFormat:@"%d",(int)[_otherPlayers count]];
}

-(void)unlockRoles{
    CCScene *store = [CCBReader loadAsScene:@"Store"];
    [[CCDirector sharedDirector] pushScene:store];
}

-(void)play{
    CCScene *roleScreen = [CCBReader loadAsScene:@"RoleSelection"];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

-(void)ghettoPlay{
    CCScene *roleScreen = [Gameplay sendTheArray:_otherPlayers];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

@end
