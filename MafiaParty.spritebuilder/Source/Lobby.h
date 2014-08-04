//
//  Lobby.h
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Lobby : CCNode{
    NSNumber* playerIndex;
}

@property (strong, nonatomic) NSMutableArray *otherPlayers;
@property (nonatomic,retain) NSNumber* playerIndex;


+(CCScene*)sendMySelf:(NSString*)UID;

@end
