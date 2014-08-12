//
//  RoleSelection.h
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCScene.h"

@interface RoleSelection : CCScene

// Other players array
@property (nonatomic, strong) NSMutableArray *playerArray;

// Arrays
@property (nonatomic, strong) NSMutableArray *nounArray;
@property (nonatomic, strong) NSMutableArray *verbArray;
@property (nonatomic, strong) NSMutableArray *adjectiveArray;
@property  (nonatomic,assign) int passedIndex;

+(CCScene*)sendTheArray:(NSMutableArray*)theArray;

@property CCLabelTTF *nextLabel;
@property CCButton *nextButton;

@end
