//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Player.h"


static NSCache *profilePictureCache;

@implementation MainScene{
    Firebase *_myRootRef;
    FirebaseSimpleLogin *_authClient;
    Firebase *_authRef;
    CCSprite *_IMAGE;
    CCSprite *_testSprite;
}

-(void)didLoadFromCCB{
    _myRootRef = [[Firebase alloc] initWithUrl:@"https://mafiagame.firebaseio.com/"];
    _authClient = [[FirebaseSimpleLogin alloc] initWithRef:_myRootRef];
    
    
}

-(void)onEnter{
    [super onEnter];
    [_authClient checkAuthStatusWithBlock:^(NSError* error, FAUser* user) {
        if (error != nil) {
            // an error occurred while attempting login
            NSLog(@"%@", error);
        } else if (user == nil) {
            // No user is logged in
        } else {
            // user authenticated with Firebase
            NSLog(@"%@", user);
        }
    }];
}
-(void)startGame
{
    
}

-(void)logInWithFacebook{
    [_authClient loginToFacebookAppWithId:@"750925491636225" permissions:@[@"email"]
                                audience:ACFacebookAudienceOnlyMe
                     withCompletionBlock:^(NSError *error, FAUser *user) {
                         
                         if (error != nil) {
                             // There was an error logging in
                         } else {
                             // We have a logged in Facebook user
                             NSDictionary *newUser = user.thirdPartyUserData;
                             
                             NSString *_tempName = [newUser valueForKey:@"displayName"];
                             CCLOG(@"NAME : %@",_tempName);
                             NSURL *_tempImage = [NSURL URLWithString:[newUser valueForKey:@"picture"][@"data"][@"url"]] ;
                             NSString *_tempImagez = [newUser valueForKey:@"picture"][@"data"][@"url"] ;
                             CCLOG(@"URL : %@", _tempImage);
                             NSURL *url = [NSURL URLWithString:_tempImagez];
                             NSData *data = [NSData dataWithContentsOfURL:url];
                             UIImage *image = [UIImage imageWithData:data];

                             _testSprite.visible = false;
                             //convert UIImage to CCSprite
                             CCTexture *texture = [[CCTexture alloc]initWithCGImage:image.CGImage contentScale:1.f];
                             _IMAGE.spriteFrame = [CCSpriteFrame frameWithTexture:texture rectInPixels:CGRectMake(0.f, 0.f, 100.f, 100.f) rotated:NO offset:ccp(0,0) originalSize:CGSizeMake(1.f, 1.f)];
                             [_me setMe:_tempName andMyPicture:_IMAGE];
                             
                         }
                     }];
    
    _authRef = [_myRootRef.root childByAppendingPath:@".info/authenticated"];
    [_authRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
        BOOL isAuthenticated = [snapshot.value boolValue];
        CCLOG(isAuthenticated ? @"Yes" : @"No");
    }];
}

-(void) toTheLobby {
    CCScene *lobby = [CCBReader loadAsScene:@"Lobby"];
    [[CCDirector sharedDirector] replaceScene:lobby];
}

-(void)results{
    CCScene *results = (CCScene *)[CCBReader load:@"Results"];
    [[CCDirector sharedDirector] replaceScene:results];
}

@end
