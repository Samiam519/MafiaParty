//
//  Lobby.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Lobby.h"
#import "Gameplay.h"
#import "Player.h"

@implementation Lobby
{
    // Labels
    CCLabelTTF *_playersReadyLabel;
    CCLabelTTF *_mafiaPlayersLabel;
    CCLabelTTF *_playLabel;
    
    CCButton *_playButton;
    
    Firebase *lobbyRef;
    CCNode *_iconNode;
    
    Player *_me;
    int i;
    NSString *myUniqueID;
    int indexOfSelf;
}

+(CCScene*)sendMySelf:(NSString*)UID{
    CCScene *newScene = [CCScene node];
    [newScene addChild:[self gameplayWithUID:UID]];
    return newScene;
}

+(id)gameplayWithUID:(NSString*)UID{
    return [[self alloc]initWithUID:(NSString*)UID];
}

-(id)initWithUID:(NSString*)UID{
    
    if((self = (Lobby *) [CCBReader load:@"Lobby"])){
        myUniqueID = UID;
    }
    return self;
}

-(void)didLoadFromCCB{
    i=0;
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
        newImage.spriteFrame = [CCSpriteFrame frameWithTexture:texture rectInPixels:CGRectMake(0.f, 0.f, 50.f, 50.f) rotated:NO offset:ccp(1,1) originalSize:CGSizeMake(1.f, 1.f)];
        [newPlayer setMe:snapshot.value[@"Name"] andMyPicture:newImage];

        [_otherPlayers addObject:newPlayer];
        Player *childSprite = _iconNode.children[i];
        Player *curPlayer = _otherPlayers[i];
        childSprite.icon.spriteFrame = curPlayer.icon.spriteFrame;
        childSprite.FBname = curPlayer.FBname;
//        childSprite.positionType = CCPositionTypeMake(0.2, 0.2, CCPositionReferenceCornerTopLeft);
//        childSprite[i].position = (_iconNode.children[i]).position;
                indexOfSelf = [_otherPlayers indexOfObject:newPlayer];
        i++;
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
    if (_otherPlayers.count < 7) {
        _mafiaPlayersLabel.string = @"1";
    }
    else if (_otherPlayers.count < 11) {
        _mafiaPlayersLabel.string = @"2";
    }
    else if (_otherPlayers.count > 10) {
        _mafiaPlayersLabel.string = @"3";
    }
    
    if ([_otherPlayers count] < 4)
    {
        _playLabel.string = @"Wait for more players";
        _playButton.enabled = FALSE;
    }
    else if ([_otherPlayers count] >= 4)
    {
        _playLabel.string = @"PLAY";
        _playButton.enabled = TRUE;
    }
        
}

-(void)onEnter{
    [super onEnter];
    _playersReadyLabel.string = [NSString stringWithFormat:@"%d",(int)[_otherPlayers count]];
}

- (void)unlockRoles
{
    // Load the Store
    CCScene *store = (CCScene *)[CCBReader loadAsScene:@"Store"];
    [[CCDirector sharedDirector] pushScene:store];
}

- (void)play
{
    // Load Role Selection
    CCScene *roleScreen = (CCScene *)[CCBReader loadAsScene:@"RoleSelection"];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

- (void)gameplay
{
    // GHETTOOOOOOOOOOO

    CCScene *roleScreen = [Gameplay sendMySelf:indexOfSelf];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

@end
