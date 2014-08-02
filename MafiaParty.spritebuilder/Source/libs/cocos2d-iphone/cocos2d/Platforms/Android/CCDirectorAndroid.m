//
//  CCDirectorAndroid.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 5/22/14.
//
//

#import "CCDirectorAndroid.h"

#if __CC_PLATFORM_ANDROID

#import "CCDirector_Private.h"

#import "../../CCScheduler.h"
#import "../../CCActionManager.h"
#import "../../CCTextureCache.h"
#import "../../CCMacros.h"
#import "../../CCScene.h"
#import "../../CCShader.h"
#import "../../CCFPSImages.h"
#import "../../CCConfiguration.h"
#import "CCRenderer_private.h"
#import "CCGLQueue.h"
#import "CCTouch.h"


#pragma mark -
#pragma mark Director

@interface CCDirector ()
-(void) setNextScene;
-(void) showStats;
-(void) calculateDeltaTime;
-(void) calculateMPF;
@end



#pragma mark -
#pragma mark CCDirectorAndroid

@implementation CCDirectorAndroid

- (id) init
{
	if( (self=[super init]) ) {
		// main thread
		_runningThread = [NSThread currentThread];
	}
    
	return self;
}


//
// Draw the Scene
//
- (void) drawScene
{
    /* calculate "global" dt */
	[self calculateDeltaTime];
    
	CCGLView *openGLview = (CCGLView*)self.view;

	/* tick before glClear: issue #533 */
	if( ! _isPaused ) [_scheduler update: _dt];
    
	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( _nextScene ) [self setNextScene];
	
	CCMatrix4 projection = self.projectionMatrix;
	_renderer.globalShaderUniforms = [self updateGlobalShaderUniforms];
	
	[CCRenderer bindRenderer:_renderer];
	[_renderer invalidateState];
	
	[_renderer enqueueClear:(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) color:_runningScene.colorRGBA.CCVector4 depth:1.0f stencil:0 globalSortOrder:NSIntegerMin];
	
	// Render
	[_runningScene visit:_renderer parentTransform:&projection];
	[_notificationNode visit:_renderer parentTransform:&projection];
	if( _displayStats ) [self showStats];
	
	[_renderer flush];
	[CCRenderer bindRenderer:nil];
	
	[openGLview swapBuffers];
    
	_totalFrames++;
    
	if( _displayStats ) [self calculateMPF];
}

-(void) setViewport
{
	CGSize size = _winSizeInPixels;
	glViewport(0, 0, size.width, size.height );
}

-(void) setProjection:(CCDirectorProjection)projection
{
	CGSize sizePoint = _winSizeInPoints;
    
	[self setViewport];
    
	switch (projection) {
		case CCDirectorProjection2D:
			_projectionMatrix = CCMatrix4MakeOrtho(0, sizePoint.width, 0, sizePoint.height, -1024, 1024 );
			break;
            
		case CCDirectorProjection3D: {
			float zeye = sizePoint.height*sqrtf(3.0f)/2.0f;
			_projectionMatrix = CCMatrix4Multiply(
                                                   CCMatrix4MakePerspective(CC_DEGREES_TO_RADIANS(60), (float)sizePoint.width/sizePoint.height, 0.1f, zeye*2),
                                                   CCMatrix4MakeTranslation(-sizePoint.width/2.0, -sizePoint.height/2, -zeye)
                                                   );
            
			break;
		}
            
		default:
			CCLOG(@"cocos2d: Director: unrecognized projection");
			break;
	}
    
	_projection = projection;
	[self createStatsLabel];
}

// override default logic
- (void) runWithScene:(CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	NSAssert(_runningScene == nil, @"This command can only be used to start the CCDirector. There is already a scene present.");
	
	[self pushScene:scene];
    
	NSThread *thread = [self runningThread];
	[self performSelector:@selector(drawScene) onThread:thread withObject:nil waitUntilDone:YES];
}

// overriden, don't call super
-(void) reshapeProjection:(CGSize)size
{
	_winSizeInPixels = size;
	_winSizeInPoints = CGSizeMake(size.width/__ccContentScaleFactor, size.height/__ccContentScaleFactor);
	
	[self setProjection:_projection];
    
    [self.runningScene viewDidResizeTo: _winSizeInPoints];
}

-(void)end
{
	[super end];
}

-(void) setView:(CCGLView *)view
{
	if( view != __view) {
		[super setView:view];
		if( view ) {
			// set size
			CGFloat scale = view.contentScaleFactor;
			CGSize size = view.bounds.size;
			_winSizeInPixels = CGSizeMake(size.width * scale, size.height * scale);
		}
	}
}

- (void)runBlock:(dispatch_block_t)block
{
    [[CCActivity currentActivity] runOnGameThread:block];
}

@end


#pragma mark -
#pragma mark DirectorDisplayLink

@implementation CCDirectorDisplayLink

-(void) mainLoop:(id)sender
{
    EGLDisplay display;
    EGLSurface surfaceR;
    EGLSurface surfaceD;

    EGLContext ctx = eglGetCurrentContext();

    BOOL needsRestore = NO;
    EGLContext appContext = self.view.eglContext;
    if (appContext != ctx)
    {
        display = eglGetCurrentDisplay();
        surfaceD = eglGetCurrentSurface(EGL_DRAW);
        surfaceR = eglGetCurrentSurface(EGL_READ);
        
        EGLSurface surface = self.view.eglSurface;
        
        eglMakeCurrent(self.view.eglDisplay, surface, surface, appContext);
        needsRestore = YES;
    }
    
	[self drawScene];
    
    if (needsRestore)
    {
        eglMakeCurrent(display, surfaceD, surfaceR, ctx);
    }
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
    
	_animationInterval = interval;
	if(_displayLink)
    {
		[self stopAnimation];
		[self startAnimation];
	}
}

- (void) startAnimation
{
	[super startAnimation];
    
    if(_animating)
        return;
    
	gettimeofday( &_lastUpdate, NULL);
    
	// approximate frame rate
	// assumes device refreshes at 60 fps
    
	CCLOG(@"cocos2d: animation started with frame interval: %d", (int)floorf(_animationInterval * 60.0));
    
    _displayLink = [NSTimer scheduledTimerWithTimeInterval:_animationInterval
                                             target:self
                                           selector:@selector(mainLoop:)
                                           userInfo:nil repeats:YES];
    
    _animating = YES;
}

- (void) stopAnimation
{
    if(!_animating)
        return;
    
	CCLOG(@"cocos2d: animation stopped");
    
	[_runningThread cancel];
//	[_runningThread release];
	_runningThread = nil;
    
	[_displayLink invalidate];
	_displayLink = nil;
    _animating = NO;
}

// Overriden in order to use a more stable delta time
-(void) calculateDeltaTime
{
    static unsigned long long last = 0;
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    unsigned long long now = t.tv_sec * 1e9 + t.tv_nsec;
    if (now != last)
    {
        if (last != 0)
        {
            _dt = (now - last) / (double)NSEC_PER_SEC;
        }
        last = now;
    }
}


#pragma mark Director Thread

//
// Director has its own thread
//
-(void) threadMainLoop
{
	@autoreleasepool {
        [[NSRunLoop currentRunLoop] addTimer:_displayLink forMode:NSRunLoopCommonModes];
        
		// start the run loop
		[[NSRunLoop currentRunLoop] run];
	}
}

@end

#endif //__CC_PLATFORM_ANDROID

