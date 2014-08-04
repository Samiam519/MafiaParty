/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCRenderTexture.h"
#import "CCDirector.h"
#import "CCMacros.h"
#import "CCShader.h"
#import "CCConfiguration.h"
#import "Support/CCUtils.h"
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"

#import "CCTexture_Private.h"
#import "CCDirector_Private.h"
#import "CCNode_Private.h"
#import "CCRenderer_private.h"
#import "CCRenderTexture_Private.h"
#if __CC_PLATFORM_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif


@interface CCRenderTextureSprite : CCSprite @end
@implementation CCRenderTextureSprite

-(CCRenderState *)renderState
{
	if(_renderState == nil){
		if(_shaderUniforms.count > 1){
			_renderState = [[CCRenderState alloc] initWithBlendMode:_blendMode shader:_shader shaderUniforms:_shaderUniforms];
		} else {
			// Creating a regular, cached render state here would be mildly bad.
			// The state would prevent the render texture from being released until the cache is flushed.
			NSDictionary *uniforms = @{CCShaderUniformMainTexture:(_texture ?: [CCTexture none])};
			_renderState = [[CCRenderState alloc] initWithBlendMode:_blendMode shader:_shader shaderUniforms:uniforms];
		}
	}
	
	return _renderState;
}

@end


@interface CCRenderTextureFBO : NSObject

@property (nonatomic, readonly) GLuint FBO;
@property (nonatomic, readonly) GLuint depthRenderBuffer;
@property (nonatomic, readonly) GLuint stencilRenderBuffer;

@end

@implementation CCRenderTextureFBO

- (id)initWithFBO:(GLuint)fbo depthRenderBuffer:(GLuint)depthBuffer stencilRenderBuffer:(GLuint)stencilRenderBuffer
{
    if((self = [super init]))
    {
        _FBO = fbo;
        _depthRenderBuffer = depthBuffer;
        _stencilRenderBuffer = stencilRenderBuffer;
    }
    return self;
}

@end

@implementation CCRenderTexture

+(id)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat) format depthStencilFormat:(GLuint)depthStencilFormat
{
  return [[self alloc] initWithWidth:w height:h pixelFormat:format depthStencilFormat:depthStencilFormat];
}

// issue #994
+(id)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format
{
	return [[self alloc] initWithWidth:w height:h pixelFormat:format];
}

+(id)renderTextureWithWidth:(int)w height:(int)h
{
	return [[self alloc] initWithWidth:w height:h pixelFormat:CCTexturePixelFormat_RGBA8888 depthStencilFormat:0];
}

-(id)initWithWidth:(int)w height:(int)h
{
	return [self initWithWidth:w height:h pixelFormat:CCTexturePixelFormat_RGBA8888];
}

- (id)initWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format
{
  return [self initWithWidth:w height:h pixelFormat:format depthStencilFormat:0];
}

-(id)initWithWidth:(int)width height:(int)height pixelFormat:(CCTexturePixelFormat) format depthStencilFormat:(GLuint)depthStencilFormat
{
	if((self = [super init])){
        
		NSAssert(format != CCTexturePixelFormat_A8, @"only RGB and RGBA formats are valid for a render texture");

		CCDirector *director = [CCDirector sharedDirector];

		// XXX multithread
		if( [director runningThread] != [NSThread currentThread] )
			CCLOGWARN(@"cocos2d: WARNING. CCRenderTexture is running on its own thread. Make sure that an OpenGL context is being used on this thread!");

		_contentScale = [CCDirector sharedDirector].contentScaleFactor;
        [self setContentSize:CGSizeMake(width, height)];
		_pixelFormat = format;
		_depthStencilFormat = depthStencilFormat;

		// Flip the projection matrix on the y-axis since Cocos2D uses upside down textures.
		_projection = CCMatrix4MakeOrtho(0.0f, width, 0.0f, height, -1024.0f, 1024.0f);
		
		_sprite = [CCRenderTextureSprite spriteWithTexture:[CCTexture none]];

		// Diabled by default.
		_autoDraw = NO;
		
		// add sprite for backward compatibility
		[self addChild:_sprite];
	}
	return self;
}


-(id)init
{
    return [self initWithWidth:0 height:0 pixelFormat:CCTexturePixelFormat_RGBA8888];
}

-(void)create
{
#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
	glPushGroupMarkerEXT(0, "CCRenderTexture: Create");
#endif

	int pixelW = _contentSize.width*_contentScale;
	int pixelH = _contentSize.height*_contentScale;
    
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);

	// textures must be power of two
	NSUInteger powW;
	NSUInteger powH;
    
    if( [[CCConfiguration sharedConfiguration] supportsNPOT] ) {
		powW = pixelW;
		powH = pixelH;
	} else {
		powW = CCNextPOT(pixelW);
		powH = CCNextPOT(pixelH);
	}
    
	void *data = calloc(powW*powH, 4);

	CCTexture *texture = [[CCTexture alloc] initWithData:data pixelFormat:_pixelFormat pixelsWide:powW pixelsHigh:powH contentSizeInPixels:CGSizeMake(pixelW, pixelH) contentScale:_contentScale];
    self.texture = texture;
    
	free(data);

	GLint oldRBO;
	glGetIntegerv(GL_RENDERBUFFER_BINDING, &oldRBO);

	// generate FBO
	GLuint fbo;
	glGenFramebuffers(1, &fbo);
	glBindFramebuffer(GL_FRAMEBUFFER, fbo);

	// associate texture with FBO
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.name, 0);

	GLuint depthRenderBuffer = 0;
    GLuint stencilRenderBuffer = 0;
    
#if __CC_PLATFORM_ANDROID
    
    // Some android devices *only* support combined depth buffers (like all iOS devices), some android devices do not
    // support combined depth buffers, thus we have to create a seperate stencil buffer
    if(_depthStencilFormat)
    {
        //create and attach depth buffer
		
        if(![[CCConfiguration sharedConfiguration] supportsPackedDepthStencil])
        {
            glGenRenderbuffers(1, &depthRenderBuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, (GLsizei)powW, (GLsizei)powH); //GL_DEPTH_COMPONENT24_OES
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);

            // if depth format is the one with stencil part, bind same render buffer as stencil attachment
            if(_depthStencilFormat == GL_DEPTH24_STENCIL8)
            {
                glGenRenderbuffers(1, &stencilRenderBuffer);
                glBindRenderbuffer(GL_RENDERBUFFER, stencilRenderBuffer);
                glRenderbufferStorage(GL_RENDERBUFFER, GL_STENCIL_INDEX8, (GLsizei)powW, (GLsizei)powH);
                glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, stencilRenderBuffer);
            }
        }
        else
        {
            glGenRenderbuffers(1, &depthRenderBuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
            glRenderbufferStorage(GL_RENDERBUFFER, _depthStencilFormat, (GLsizei)powW, (GLsizei)powH);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
            
            // if depth format is the one with stencil part, bind same render buffer as stencil attachment
            if(_depthStencilFormat == GL_DEPTH24_STENCIL8){
                glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
            }
        }
	}
    
#else
    
	if(_depthStencilFormat)
    {
		//create and attach depth buffer
		glGenRenderbuffers(1, &depthRenderBuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
		glRenderbufferStorage(GL_RENDERBUFFER, _depthStencilFormat, (GLsizei)powW, (GLsizei)powH);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);

		// if depth format is the one with stencil part, bind same render buffer as stencil attachment
		if(_depthStencilFormat == GL_DEPTH24_STENCIL8){
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
		}
	}
#endif
    
	// check if it worked (probably worth doing :) )
	NSAssert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Could not attach texture to framebuffer");

    _FBO = [[CCRenderTextureFBO alloc] initWithFBO:fbo depthRenderBuffer:depthRenderBuffer stencilRenderBuffer:stencilRenderBuffer];
    
	[texture setAliasTexParameters];
	
	glBindRenderbuffer(GL_RENDERBUFFER, oldRBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
	
	CC_CHECK_GL_ERROR_DEBUG();
#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
	glPopGroupMarkerEXT();
#endif
	
	CGRect rect = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
	
	[self assignSpriteTexture];
	[_sprite setTextureRect:rect];
}

-(void)assignSpriteTexture
{
    _sprite.texture = self.texture;
}

-(void)setContentScale:(float)contentScale
{
	if(_contentScale != contentScale){
		_contentScale = contentScale;
		
		[self destroy];
	}
}

-(void)destroy
{
    GLuint fbo = _FBO.FBO;
    glDeleteFramebuffers(1, &fbo);
	
    GLuint depthRenderBuffer = _FBO.depthRenderBuffer;
    if (depthRenderBuffer)
    {
        glDeleteRenderbuffers(1, &depthRenderBuffer);
    }
    
    GLuint stencilRenderBuffer = _FBO.stencilRenderBuffer;
    if (depthRenderBuffer)
    {
        glDeleteRenderbuffers(1, &stencilRenderBuffer);
    }

    _FBO = nil;
    self.texture = nil;
}

-(void)dealloc
{
	[self destroy];
}

-(CCTexture *)texture
{
    if (super.texture == nil)
    {
        [self create];
    }
    
    return super.texture;
}

-(GLuint)fbo
{
    if (super.texture == nil)
    {
        [self create];
    }
    
    return _FBO.FBO;
}

-(void)begin
{
	_renderer = [CCRenderer currentRenderer];
	
	if(_renderer == nil){
		_renderer = [[CCRenderer alloc] init];
		
		NSMutableDictionary *uniforms = [[CCDirector sharedDirector].globalShaderUniforms mutableCopy];
		uniforms[CCShaderUniformProjection] = [NSValue valueWithCCMatrix4:_projection];
		_renderer.globalShaderUniforms = uniforms;
		
		[CCRenderer bindRenderer:_renderer];
		_privateRenderer = YES;
	} else {
		_oldGlobalUniforms = _renderer.globalShaderUniforms;
		
		NSMutableDictionary *uniforms = [_oldGlobalUniforms mutableCopy];
		uniforms[CCShaderUniformProjection] = [NSValue valueWithCCMatrix4:_projection];
		_renderer.globalShaderUniforms = uniforms;
	}
	
	CGSize pixelSize = self.texture.contentSizeInPixels;
	GLuint fbo = [self fbo];
	
	[_renderer pushGroup];
	
	[_renderer enqueueBlock:^{
		glGetFloatv(GL_VIEWPORT, _oldViewport.v);
		glViewport(0, 0, pixelSize.width, pixelSize.height );
		
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
		glBindFramebuffer(GL_FRAMEBUFFER, fbo);
	} globalSortOrder:NSIntegerMin debugLabel:@"CCRenderTexture: Bind FBO" threadSafe:NO];
}

-(void)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a depth:(float)depthValue stencil:(int)stencilValue flags:(GLbitfield)flags
{
	[self begin];
	[_renderer enqueueClear:flags color:CCVector4Make(r, g, b, a) depth:depthValue stencil:stencilValue globalSortOrder:NSIntegerMin];
}

-(void)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a
{
	[self beginWithClear:r g:g b:b a:a depth:0 stencil:0 flags:GL_COLOR_BUFFER_BIT];
}

-(void)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a depth:(float)depthValue
{
	[self beginWithClear:r g:g b:b a:a depth:depthValue stencil:0 flags:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
}

-(void)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a depth:(float)depthValue stencil:(int)stencilValue
{
	[self beginWithClear:r g:g b:b a:a depth:depthValue stencil:stencilValue flags:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT];
}

-(void)end
{
	[_renderer enqueueBlock:^{
		glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
		glViewport(_oldViewport.v[0], _oldViewport.v[1], _oldViewport.v[2], _oldViewport.v[3]);
	} globalSortOrder:NSIntegerMax debugLabel:@"CCRenderTexture: Restore FBO" threadSafe:NO];
	
	[_renderer popGroupWithDebugLabel:@"CCRenderTexture begin/end" globalSortOrder:0];
	
	if(_privateRenderer){
		[_renderer flush];
		[CCRenderer bindRenderer:nil];
		_privateRenderer = NO;
	} else {
		_renderer.globalShaderUniforms = _oldGlobalUniforms;
	}
	
	_renderer = nil;
}

-(void)clear:(float)r g:(float)g b:(float)b a:(float)a
{
	[self beginWithClear:r g:g b:b a:a];
	[self end];
}

- (void)clearDepth:(float)depthValue
{
	[self begin];
		[_renderer enqueueClear:GL_DEPTH_BUFFER_BIT color:CCVector4Make(0, 0, 0, 0) depth:depthValue stencil:0 globalSortOrder:NSIntegerMin];
	[self end];
}

- (void)clearStencil:(int)stencilValue
{
	[self begin];
		[_renderer enqueueClear:GL_DEPTH_BUFFER_BIT color:CCVector4Make(0, 0, 0, 0) depth:0.0 stencil:stencilValue globalSortOrder:NSIntegerMin];
	[self end];
}

#pragma mark RenderTexture - "auto" update

- (void)visit:(CCRenderer *)renderer parentTransform:(const CCMatrix4 *)parentTransform
{
	// override visit.
	// Don't call visit on its children
	if(!_visible) return;
	
	if(_autoDraw){
        
        if(_contentSizeChanged)
        {
            [self destroy];
            _contentSizeChanged = NO;
        }
        
		[self begin];
		NSAssert(_renderer == renderer, @"CCRenderTexture error!");
		
		[_renderer enqueueClear:_clearFlags color:_clearColor depth:_clearDepth stencil:_clearStencil globalSortOrder:NSIntegerMin];
		
		//! make sure all children are drawn
		[self sortAllChildren];
		
		for(CCNode *child in _children){
			if( child != _sprite) [child visit:renderer parentTransform:&_projection];
		}
		
		[self end];
	}
	
	CCMatrix4 transform = [self transform:parentTransform];
	[_sprite visit:renderer parentTransform:&transform];
	
	_orderOfArrival = 0;
}

#pragma mark RenderTexture - Save Image

-(CGImageRef) newCGImage
{
	NSAssert(_pixelFormat == CCTexturePixelFormat_RGBA8888,@"only RGBA8888 can be saved as image");
	
	CGSize s = [self.texture contentSizeInPixels];
	int tx = s.width;
	int ty = s.height;
	
	int bitsPerComponent = 8;
	int bitsPerPixel = 4 * 8;
	int bytesPerPixel = bitsPerPixel / 8;
	int bytesPerRow = bytesPerPixel * tx;
	NSInteger myDataLength = bytesPerRow * ty;
	
	GLubyte *buffer	= calloc(myDataLength,1);
	GLubyte *pixels	= calloc(myDataLength,1);
	
	
	if( ! (buffer && pixels) ) {
		CCLOG(@"cocos2d: CCRenderTexture#getCGImageFromBuffer: not enough memory");
		free(buffer);
		free(pixels);
		return nil;
	}
	
    [self begin];
    [_renderer enqueueBlock:^
    {
        glReadPixels(0,0,tx,ty,GL_RGBA,GL_UNSIGNED_BYTE, buffer);
    } globalSortOrder:NSIntegerMax debugLabel:@"CCRenderTexture reading pixels for new image" threadSafe:NO];
    [self end];
	
	// make data provider with data.
	
	CGBitmapInfo bitmapInfo	= kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, myDataLength, NULL);
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGImageRef iref	= CGImageCreate(tx, ty,
									bitsPerComponent, bitsPerPixel, bytesPerRow,
									colorSpaceRef, bitmapInfo, provider,
									NULL, false,
									kCGRenderingIntentDefault);
	
	CGContextRef context = CGBitmapContextCreate(pixels, tx,
												 ty, CGImageGetBitsPerComponent(iref),
												 CGImageGetBytesPerRow(iref), CGImageGetColorSpace(iref),
												 bitmapInfo);
	
	// vertically flipped
	if( YES ) {
		CGContextTranslateCTM(context, 0.0f, ty);
		CGContextScaleCTM(context, 1.0f, -1.0f);
	}
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, tx, ty), iref);
	CGImageRef image = CGBitmapContextCreateImage(context);
	
	CGContextRelease(context);
	CGImageRelease(iref);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	
	free(pixels);
	free(buffer);
	
	return image;
}

-(BOOL) saveToFile:(NSString*)name
{
	return [self saveToFile:name format:CCRenderTextureImageFormatJPEG];
}

-(BOOL)saveToFile:(NSString*)fileName format:(CCRenderTextureImageFormat)format
{
	BOOL success = YES;
	
	NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];

    return [self saveToFilePath:fullPath format:format];
}

- (BOOL)saveToFilePath:(NSString *)filePath
{
    return [self saveToFilePath:filePath format:CCRenderTextureImageFormatJPEG];
}

- (BOOL)saveToFilePath:(NSString *)filePath format:(CCRenderTextureImageFormat)format
{
    BOOL success = NO;

   	CGImageRef imageRef = [self newCGImage];

   	if( ! imageRef ) {
   		CCLOG(@"cocos2d: Error: Cannot create CGImage ref from texture");
   		return NO;
   	}

#if __CC_PLATFORM_IOS
   	CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
   	UIImage* image	= [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
   	NSData *imageData = nil;

   	if( format == CCRenderTextureImageFormatPNG )
   		imageData = UIImagePNGRepresentation( image );

   	else if( format == CCRenderTextureImageFormatJPEG )
   		imageData = UIImageJPEGRepresentation(image, 0.9f);

   	else
   		NSAssert(NO, @"Unsupported format");

   	success = [imageData writeToFile:filePath atomically:YES];

#elif __CC_PLATFORM_MAC
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:filePath];

    CGImageDestinationRef dest;

    if( format == CCRenderTextureImageFormatPNG )
        dest = 	CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);

    else if( format == CCRenderTextureImageFormatJPEG )
        dest = 	CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);

    else
        NSAssert(NO, @"Unsupported format");

    if (!dest)
    {
        CCLOG(@"cocos2d: ERROR: Failed to create image destination with file path:%@", filePath);
        CGImageRelease(imageRef);
        return NO;
    }

    CGImageDestinationAddImage(dest, imageRef, nil);

    success = CGImageDestinationFinalize(dest);

    CFRelease(dest);
#endif

    CGImageRelease(imageRef);

    if( ! success )
        CCLOG(@"cocos2d: ERROR: Failed to save file:%@ to disk", filePath);

    return success;
}


#if __CC_PLATFORM_IOS

-(UIImage *) getUIImage
{
	CGImageRef imageRef = [self newCGImage];
	
	CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
	UIImage* image	= [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    
	CGImageRelease( imageRef );
    
	return image;
}
#endif // __CC_PLATFORM_IOS

- (CCColor*) clearColor
{
    return [CCColor colorWithCCVector4:_clearColor];
}

- (void) setClearColor:(CCColor *)clearColor
{
    _clearColor = clearColor.CCVector4;
}

#pragma RenderTexture - Override

-(void) setContentSize:(CGSize)size
{
    // TODO: Fix CCRenderTexture so that it correctly handles this
	// NSAssert(NO, @"You cannot change the content size of an already created CCRenderTexture. Recreate it");
    [super setContentSize:size];
    _projection = CCMatrix4MakeOrtho(0.0f, size.width, 0.0f, size.height, -1024.0f, 1024.0f);
    _contentSizeChanged = YES;
}

@end

