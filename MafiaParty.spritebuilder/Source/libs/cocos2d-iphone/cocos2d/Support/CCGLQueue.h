//
//  CCGLQueue.h
//  CCGLQueue
//
//  Created by Philippe Hausler on 5/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#if !__CC_PLATFORM_MAC
#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

@interface CCGLQueue : NSThread

+ (instancetype)mainQueueWithAPI:(EAGLRenderingAPI)api;

+ (instancetype)queueWithAPI:(EAGLRenderingAPI)api;

- (instancetype)initWithAPI:(EAGLRenderingAPI)api;

- (void)addOperation:(void (^)(EAGLContext *))block;

// If we are already on the corrent thread, then just execute operation, otherwise add the operation to our queue
- (void)executeOperation:(void (^)(EAGLContext *))block;

- (void)flush;

@end
#endif
