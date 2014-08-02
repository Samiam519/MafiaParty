/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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


#import "CCLabelTTF.h"
#import "Support/CGPointExtension.h"
#import "CCMacros.h"
#import "CCShader.h"
#import "Support/CCFileUtils.h"
#import "CCMacros.h"
#import "CCUtils.h"
#import "NSAttributedString+CCAdditions.h"
#import "CCConfiguration.h"
#import "CCNode_Private.h"
#import "CCDirector.h"

#if __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#endif

#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID
#import <CoreText/CoreText.h>
#endif





static __strong NSMutableDictionary* ccLabelTTF_registeredFonts;


@implementation CCTexture (CCLabelTTF)

- (void) setPremultipliedAlpha:(BOOL)flag
{
    _premultipliedAlpha = flag;
}

@end

#pragma mark CCLabelTTF


@implementation CCLabelTTF
+ (void)registerFontsFromAppBundle {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        NSArray *bundledFonts = [NSBundle mainBundle].infoDictionary[@"UIAppFonts"];
        NSBundle *appBundle = [NSBundle mainBundle];
        
        for (NSString *fontName in bundledFonts) {
            NSURL *fontURL = [appBundle URLForResource:fontName withExtension:nil];

            if (fontURL != nil) {
                CTFontManagerRegisterFontsForURL((CFURLRef)fontURL, kCTFontManagerScopeProcess, NULL);
            }
        }
    });

}

+ (id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size
{
    return [[self alloc] initWithString:string fontName:name fontSize:size];
}

+ (id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions
{
    return [[self alloc] initWithString:string fontName:name fontSize:size dimensions:dimensions];
}

+ (id) labelWithAttributedString:(NSAttributedString *)attrString
{
    return [[self alloc] initWithAttributedString:attrString];
}

+ (id) labelWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions
{
    return [[self alloc] initWithAttributedString:attrString dimensions:dimensions];
}

- (id) init
{
    return [self initWithString:@"" fontName:@"Helvetica" fontSize:12];
}


- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithAttributedString:[[NSAttributedString alloc] initWithString:str] fontName:name fontSize:size dimensions:CGSizeZero];
}

- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions
{
    return [self initWithAttributedString:[[NSAttributedString alloc] initWithString:str] fontName:name fontSize:size dimensions:dimensions];
}

- (id) initWithAttributedString:(NSAttributedString *)attrString;
{
    NSAssert([CCConfiguration sharedConfiguration].OSVersion >= CCSystemVersion_iOS_6_0, @"Attributed strings are only supported on iOS 6 or later");
    return [self initWithAttributedString:attrString fontName:@"Helvetica" fontSize:12 dimensions:CGSizeZero];
}

- (id) initWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions
{
    NSAssert([CCConfiguration sharedConfiguration].OSVersion >= CCSystemVersion_iOS_6_0, @"Attributed strings are only supported on iOS 6 or later");
    return [self initWithAttributedString:attrString fontName:@"Helvetica" fontSize:12 dimensions:dimensions];
}

// This is a private initializer
- (id) initWithAttributedString:(NSAttributedString *)attrString fontName:(NSString*)fontName fontSize:(CGFloat)fontSize dimensions:(CGSize)dimensions
{
    if ( (self = [super init]) )
    {
        [[self class] registerFontsFromAppBundle];
        if (!fontName) fontName = @"Helvetica";
        if (!fontSize) fontSize = 12;
        
				self.blendMode = [CCBlendMode premultipliedAlphaMode];
        
        // other properties
        self.fontName = fontName;
        self.fontSize = fontSize;
        self.dimensions = dimensions;
        self.fontColor = [CCColor whiteColor];
        self.shadowColor = [CCColor clearColor];
        self.outlineColor = [CCColor clearColor];
        self.outlineWidth = 1;
        [self _setAttributedString:attrString];
    }
    return self;
}



#pragma mark Properties

- (void) _setAttributedString:(NSAttributedString *)attributedString
{
    NSAssert(attributedString, @"Invalid attributedString");
    
    if ( _attributedString.hash != attributedString.hash)
    {
        _attributedString = [attributedString copy];
        
        [self setTextureDirty];
    }
}

- (void) setAttributedString:(NSAttributedString *)attributedString
{
    NSAssert([CCConfiguration sharedConfiguration].OSVersion >= CCSystemVersion_iOS_6_0, @"Attributed strings are only supported on iOS 6 or later");
    [self _setAttributedString:attributedString];
}

- (void) setString:(NSString*)str
{
	NSAssert( str, @"Invalid string" );
    [self _setAttributedString:[[NSAttributedString alloc] initWithString:str]];
}

-(NSString*) string
{
	return [_attributedString string];
}

- (void)setFontName:(NSString*)fontName
{
    // Handle passing of complete file paths
    if ([[[fontName pathExtension] lowercaseString] isEqualToString:@"ttf"] || [[[fontName pathExtension] lowercaseString] isEqualToString:@"otf"])
    {
        fontName = [CCLabelTTF registerCustomTTF:fontName];
    }
    
	if( fontName.hash != _fontName.hash ) {
		_fontName = [fontName copy];
		[self setTextureDirty];
	}
}

- (void) setFontSize:(CGFloat)fontSize
{
	if( fontSize != _fontSize ) {
		_fontSize = fontSize;
		[self setTextureDirty];
	}
}

- (void) setAdjustsFontSizeToFit:(BOOL)adjustsFontSizeToFit
{
    if (adjustsFontSizeToFit != _adjustsFontSizeToFit)
    {
        _adjustsFontSizeToFit = adjustsFontSizeToFit;
        [self setTextureDirty];
    }
}

- (void) setFontColor:(CCColor*)fontColor
{
    if (![fontColor isEqualToColor:_fontColor])
    {
        _fontColor = fontColor;
        [self setTextureDirty];
    }
}

- (void) setMinimumFontSize:(CGFloat)minimumFontSize
{
    if (minimumFontSize != _minimumFontSize)
    {
        _minimumFontSize = minimumFontSize;
        [self setTextureDirty];
    }
}

-(void) setDimensions:(CGSize) dim
{
    if( dim.width != _dimensions.width || dim.height != _dimensions.height)
	{
        _dimensions = dim;
		[self setTextureDirty];
    }
}

- (CGSize) contentSize
{
    [self updateTexture];
    return _contentSize;
}

-(void) setHorizontalAlignment:(CCTextAlignment)alignment
{
    if (alignment != _horizontalAlignment)
    {
        _horizontalAlignment = alignment;
		[self setTextureDirty];

    }
}

-(void) setVerticalAlignment:(CCVerticalTextAlignment)verticalAlignment
{
    if (_verticalAlignment != verticalAlignment)
    {
        _verticalAlignment = verticalAlignment;
		[self setTextureDirty];
    }
}


- (void) setShadowColor:(CCColor*)shadowColor
{
    if (![shadowColor isEqualToColor:_shadowColor])
    {
        _shadowColor = shadowColor;
        [self setTextureDirty];
    }
}

- (void) setShadowOffset:(CGPoint)shadowOffset
{
    if (!CGPointEqualToPoint(_shadowOffset, shadowOffset))
    {
        _shadowOffset = shadowOffset;
        [self setTextureDirty];
    }
}

-(CGPoint)shadowOffsetInPoints
{
    return [self convertPositionToPoints:self.shadowOffset type:_shadowOffsetType];
}

- (void) setShadowBlurRadius:(CGFloat)shadowBlurRadius
{
    if (_shadowBlurRadius != shadowBlurRadius)
    {
        _shadowBlurRadius = shadowBlurRadius;
        [self setTextureDirty];
    }
}

- (void) setOutlineColor:(CCColor*)outlineColor
{
    if (![outlineColor isEqualToColor:_outlineColor])
    {
        _outlineColor = outlineColor;
        [self setTextureDirty];
    }
}

- (void) setOutlineWidth:(CGFloat)outlineWidth
{
    if (outlineWidth != _outlineWidth)
    {
        _outlineWidth = outlineWidth;
        [self setTextureDirty];
    }
}

- (NSString*) description
{
	// XXX: _string, _fontName can't be displayed here, since they might be already released

	return [NSString stringWithFormat:@"<%@ = %p | FontSize = %.1f>", [self class], self, _fontSize];
}

-(void)onEnter
{
    
    [self setTextureDirty];
    
    [super onEnter];
}

- (void) visit:(CCRenderer *)renderer parentTransform:(const CCMatrix4 *)parentTransform
{
    if (_isTextureDirty)
    {
        [self updateTexture];
    }
    
    [super visit:renderer parentTransform:parentTransform];
}

- (void) setTextureDirty
{
    _isTextureDirty = YES;
}


#pragma mark -
#pragma mark Render Font Mac & iOS 6


- (void) drawAttributedString:(NSAttributedString *)attrString inContext:(CGContextRef) context inRect:(CGRect)rect {
    CGFloat contextHeight = CGBitmapContextGetHeight(context);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(rect.origin.x, contextHeight-rect.origin.y-rect.size.height, rect.size.width, rect.size.height), NULL);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(framesetter);
    CGPathRelease(path);
    CGContextSaveGState(context);
    CGContextSetTextMatrix (context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0.0f, contextHeight);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CTFrameDraw(frame, context);
    CGContextRestoreGState(context);
    CFRelease(frame);
}

- (void) drawString:(NSString *)string withFont:(CTFontRef)font inContext:(CGContextRef) context inRect:(CGRect)rect  {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:@{(NSString *)kCTFontAttributeName: (__bridge id)font}];
    [self drawAttributedString:attrString inContext:context inRect:rect];
}

- (CGSize) sizeForString:(NSString *)string withFont:(CTFontRef)font constrainedToSize:(CGSize) size {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:@{(NSString *)kCTFontAttributeName: (__bridge id)font}];
    
    return [self sizeForAttributedString:attrString constrainedToSize:size];

}

- (CGSize) sizeForString:(NSString *)string withFont:(CTFontRef)font constrainedToWidth:(CGFloat) width {
    return [self sizeForString:string withFont:font constrainedToSize:CGSizeMake(width, 0)];
}

- (CGSize) sizeForString:(NSString *)string withFont:(CTFontRef)font {
    return [self sizeForString:string withFont:font constrainedToSize:CGSizeZero];
}

- (CGSize) sizeForAttributedString:(NSAttributedString *)attrString constrainedToSize:(CGSize) size {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    
    CFRange suggestedRange;
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, size,  &suggestedRange);
    CFRelease(framesetter);
    
    return suggestedSize;
}


- (BOOL) updateTexture
{
    if (!_attributedString) return NO;
    if (!_isTextureDirty) return NO;
    
    _isTextureDirty = NO;
    
#if __CC_PLATFORM_IOS
    // Handle fonts on iOS 5
    if ([CCConfiguration sharedConfiguration].OSVersion < CCSystemVersion_iOS_6_0)
    {
        return [self updateTextureOld];
    }
#endif
    
    // Set default values for font attributes if they are not set in the attributed string
    
    NSMutableAttributedString* formattedAttributedString = [_attributedString mutableCopy];
    NSRange fullRange = NSMakeRange(0, formattedAttributedString.length);
    
    BOOL useFullColor = NO;
    
    if (_shadowColor.alpha > 0) useFullColor = YES;
    if (_outlineColor.alpha > 0 && _outlineWidth > 0) useFullColor = YES;
    
    
#if __CC_PLATFORM_IOS && !__CC_PLATFORM_ANDROID_FIXME
    if ([formattedAttributedString hasAttribute:NSForegroundColorAttributeName]) {
        UIColor * color = [formattedAttributedString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
        [formattedAttributedString addAttribute:(id)kCTForegroundColorFromContextAttributeName value:(__bridge id)color.CGColor range:fullRange];
    }
    if ([formattedAttributedString hasAttribute:NSFontAttributeName]) {
        UIFont * font = [formattedAttributedString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
        CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        [formattedAttributedString addAttribute:(id)kCTFontAttributeName value:(__bridge id)ctFont range:fullRange];
        CFRelease(ctFont);
    }
    
    // Shadow
    if ([formattedAttributedString hasAttribute:NSShadowAttributeName])
    {
        useFullColor = YES;
    }
    
    // Text alignment
    
    if (![formattedAttributedString hasAttribute:NSParagraphStyleAttributeName])
    {
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        
        if (_horizontalAlignment == CCTextAlignmentLeft) style.alignment = NSTextAlignmentLeft;
        else if (_horizontalAlignment == CCTextAlignmentCenter) style.alignment = NSTextAlignmentCenter;
        else if (_horizontalAlignment == CCTextAlignmentRight) style.alignment = NSTextAlignmentRight;
        
        [formattedAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:fullRange];
    }


    
#elif __CC_PLATFORM_ANDROID_FIXME
    // You betcha not to have those attributes on Android, they are not supported
    assert(!NSAttributedStringHasAttribute(formattedAttributedString, @"NSParagraphStyle"));
    assert(!NSAttributedStringHasAttribute(formattedAttributedString, @"NSFont"));
    assert(!NSAttributedStringHasAttribute(formattedAttributedString, @"NSForegroundColor"));
    
    // Shadow (No CT alternative)
    if (NSAttributedStringHasAttribute(formattedAttributedString, @"NSShadow"))
    {
        useFullColor = YES;
    }
    
    if (!NSAttributedStringHasAttribute(formattedAttributedString, (id)kCTParagraphStyleAttributeName))
    {
        CTTextAlignment alignment;
        if (_horizontalAlignment == CCTextAlignmentLeft) alignment = kCTTextAlignmentLeft;
        else if (_horizontalAlignment == CCTextAlignmentCenter) alignment = kCTTextAlignmentCenter;
        else if (_horizontalAlignment == CCTextAlignmentRight) alignment = kCTTextAlignmentRight;


        CTParagraphStyleSetting paragraphStyleSettings[] = {
            {.spec = kCTParagraphStyleSpecifierAlignment,           .valueSize = sizeof(typeof(alignment)),             .value = &alignment             },

        };

        CTParagraphStyleRef style = CTParagraphStyleCreate(paragraphStyleSettings, sizeof(paragraphStyleSettings) / sizeof(CTParagraphStyleSetting));
        
        [formattedAttributedString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)(style) range:fullRange];
        CFRelease(style);
    }

#endif
    
#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID_FIXME
    // Font color
    if (!NSAttributedStringHasAttribute(formattedAttributedString, (id)kCTForegroundColorFromContextAttributeName))
    {
        if (![_fontColor isEqualToColor:[CCColor whiteColor]])
        {
            useFullColor = YES;
        }
        
        [formattedAttributedString addAttribute:(__bridge id)kCTForegroundColorAttributeName value:(__bridge id)_fontColor.CGColor range:fullRange];
    }
    else
    {
        useFullColor = YES;
    }
    
    // Font
    if (!NSAttributedStringHasAttribute(formattedAttributedString, (id)kCTFontAttributeName))
    {
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)_fontName, _fontSize, NULL);
        if (font == NULL) font = CTFontCreateWithName(CFSTR("Helvetica"), _fontSize, NULL);
        [formattedAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:fullRange];
        CFRelease(font);
    }
#elif __CC_PLATFORM_MAC
    // Font color
    if (!NSAttributedStringHasAttribute(formattedAttributedString, NSForegroundColorAttributeName))
    {
        if (![_fontColor isEqualToColor:[CCColor whiteColor]])
        {
            useFullColor = YES;
        }
        
        NSColor* color = [NSColor colorWithCalibratedRed:_fontColor.red green:_fontColor.green blue:_fontColor.blue alpha:_fontColor.alpha];
        
        [formattedAttributedString addAttribute:NSForegroundColorAttributeName value:color range:fullRange];
    }
    else
    {
        useFullColor = YES;
    }
    
    // Font
    if (!NSAttributedStringHasAttribute(formattedAttributedString, NSFontAttributeName))
    {
        NSFont* font = [NSFont fontWithName:_fontName size:_fontSize];
        if (!font) font = [NSFont fontWithName:@"Helvetica" size:_fontSize];
        [formattedAttributedString addAttribute:NSFontAttributeName value:font range:fullRange];
    }
    
    // Text alignment
    if (!NSAttributedStringHasAttribute(formattedAttributedString, (id)kCTParagraphStyleAttributeName))
    {
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        
        if (_horizontalAlignment == CCTextAlignmentLeft) style.alignment = NSLeftTextAlignment;
        else if (_horizontalAlignment == CCTextAlignmentCenter) style.alignment = NSCenterTextAlignment;
        else if (_horizontalAlignment == CCTextAlignmentRight) style.alignment = NSRightTextAlignment;
        
        [formattedAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:fullRange];
    }
#endif
    

    // Generate a new texture from the attributed string
	CCTexture *tex;

    tex = [self createTextureWithAttributedString:NSAttributedStringCopyAdjustedForContentScaleFactor(formattedAttributedString)
                                     useFullColor:useFullColor];

	if(!tex) return NO;
    
	self.shader = (useFullColor ? [CCShader positionTextureColorShader] : [CCShader positionTextureA8ColorShader]);

    // Update texture and content size
	[self setTexture:tex];
	
	CGRect rect = CGRectZero;
	rect.size = [self.texture contentSize];
	[self setTextureRect: rect];
	
	return YES;
}

- (CCTexture*) createTextureWithAttributedString:(NSAttributedString*)attributedString useFullColor:(BOOL) fullColor
{
	NSAssert(attributedString, @"Invalid attributedString");
    
    CGSize originalDimensions = _dimensions;
  
    CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
    originalDimensions.width *= scale;
    originalDimensions.height *= scale;
    
    CGSize dimensions = [self convertContentSizeToPoints:originalDimensions type:_dimensionsType];
    
    CGFloat shadowBlurRadius = _shadowBlurRadius * scale;
    CGPoint shadowOffset = ccpMult(self.shadowOffsetInPoints, scale);
    CGFloat outlineWidth = _outlineWidth * scale;
    
    BOOL hasShadow = (_shadowColor.alpha > 0);
    BOOL hasOutline = (_outlineColor.alpha > 0 && _outlineWidth > 0);
    
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    CGFloat scaleFactor = 1;
    
    CGFloat xPadding = 0;
    CGFloat yPadding = 0;
    CGFloat wDrawArea = 0;
    CGFloat hDrawArea = 0;
    
    // Calculate padding
    if (hasShadow)
    {
        xPadding = (shadowBlurRadius + fabs(shadowOffset.x));
        yPadding = (shadowBlurRadius + fabs(shadowOffset.y));
    }
    if (hasOutline)
    {
        xPadding += outlineWidth;
        yPadding += outlineWidth;
    }
    
	// Get actual rendered dimensions
    if (dimensions.height == 0)
    {
        // Get dimensions for string without dimensions of string with variable height
        dimensions = [self sizeForAttributedString:attributedString constrainedToSize:dimensions];
        
        dimensions.width = ceil(dimensions.width);
        dimensions.height = ceil(dimensions.height);
        
        wDrawArea = dimensions.width;
        hDrawArea = dimensions.height;
        
        dimensions.width += xPadding * 2;
        dimensions.height += yPadding * 2;
    }
    else if (dimensions.width > 0 && dimensions.height > 0)
    {
        wDrawArea = dimensions.width - xPadding * 2;
        hDrawArea = dimensions.height - yPadding * 2;
        
        // Handle strings with fixed dimensions
        if (_adjustsFontSizeToFit)
        {

            CGFloat fontSize = NSAttributedStringSingleFontSize(attributedString);

            if (fontSize)
            {
                // This is a string that can be resized (it only uses one font and size)
                CGSize wantedSize = [self sizeForAttributedString:attributedString constrainedToSize:CGSizeZero];
                
                CGFloat wScaleFactor = 1;
                CGFloat hScaleFactor = 1;
                if (wantedSize.width > wDrawArea)
                {
                    wScaleFactor = wDrawArea/wantedSize.width;
                }
                if (wantedSize.height > hDrawArea)
                {
                    hScaleFactor = hDrawArea/wantedSize.height;
                }
                
                if (wScaleFactor < hScaleFactor) scaleFactor = wScaleFactor;
                else scaleFactor = hScaleFactor;
            
                if (scaleFactor != 1)
                {
                    CGFloat newFontSize = fontSize * scaleFactor;
                    CGFloat minFontSize = _minimumFontSize * scale;
                    if (minFontSize && newFontSize < minFontSize) newFontSize = minFontSize;
                    attributedString = NSAttributedStringCopyWithNewFontSize(attributedString, newFontSize);
                }
            }
        }

        // Handle vertical alignment
        CGSize actualSize = [self sizeForAttributedString:attributedString constrainedToSize:CGSizeMake(wDrawArea, 0)];
        if (_verticalAlignment == CCVerticalTextAlignmentBottom)
        {
            yOffset = hDrawArea - actualSize.height;
        }
        else if (_verticalAlignment == CCVerticalTextAlignmentCenter)
        {
            yOffset = (hDrawArea - actualSize.height)/2;
        }
    }
    
    // Handle baseline adjustments
    yOffset += _baselineAdjustment * scaleFactor * scale + yPadding;
    xOffset += xPadding;
    
    // Round dimensions to nearest number that is dividable by 2
    dimensions.width = ceilf(dimensions.width/2)*2;
    dimensions.height = ceilf(dimensions.height/2)*2;
    
    // get nearest power of two
    CGSize POTSize = CGSizeMake(CCNextPOT(dimensions.width), CCNextPOT(dimensions.height));
    
	// Mac crashes if the width or height is 0
	if( POTSize.width == 0 )
		POTSize.width = 2;
    
	if( POTSize.height == 0)
		POTSize.height = 2;
    
    // Render the label - different code for Mac / iOS
    
#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID
	CGRect drawArea = CGRectMake(xOffset, yOffset, wDrawArea, hDrawArea);
    
    unsigned char* data = calloc(POTSize.width, POTSize.height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, POTSize.width, POTSize.height, 8, POTSize.width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    if (!context)
    {
        free(data);
        return NULL;
    }
    
    // Handle shadow
    if (hasShadow)
    {
        CGContextSetShadowWithColor(context, CGSizeMake(shadowOffset.x, -shadowOffset.y), shadowBlurRadius, _shadowColor.CGColor);
    }
    
    // Handle outline
    if (hasOutline)
    {
        CGContextSetTextDrawingMode(context, kCGTextFillStroke);
        CGContextSetLineWidth(context, outlineWidth * 2);
        CGContextSetLineJoin(context, kCGLineJoinRound);

        NSMutableAttributedString* outlineString = [attributedString mutableCopy];
        //[outlineString addAttribute:NSForegroundColorAttributeName value:(__bridge id)_outlineColor.CGColor range:NSMakeRange(0, outlineString.length)]; //donotcheckin
        
        [self drawAttributedString:outlineString inContext:context inRect:drawArea];

        // Don't draw shadow for main font
        CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);

        if (hasShadow)
        {
            // Draw outline again because shadow overlap
            [self drawAttributedString:outlineString inContext:context inRect:drawArea];
        }
        CGContextSetTextDrawingMode(context, kCGTextFill);
    }
    
    [self drawAttributedString:attributedString inContext:context inRect:drawArea];

    CGContextRelease(context);
    
#elif __CC_PLATFORM_MAC
    yOffset = (POTSize.height - hDrawArea) - yOffset;
	
	CGRect drawArea = CGRectMake(xOffset, yOffset, wDrawArea, hDrawArea);
	
	NSImage *image = [[NSImage alloc] initWithSize:POTSize];
	[image lockFocus];
    [[NSAffineTransform transform] set];
    
    // XXX: The shadows are for some reason scaled on OS X if a retina display is connected
    CGFloat retinaFix = 1;
    for (NSScreen* screen in [NSScreen screens])
    {
        if (screen.backingScaleFactor > retinaFix) retinaFix = screen.backingScaleFactor;
    }
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextSaveGState(context);
		CGContextConcatCTM(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, POTSize.height));
    
    // Handle shadow
    if (hasShadow || hasOutline)
    {
        NSMutableAttributedString* effectsString = [attributedString mutableCopy];
        
        if (hasShadow)
        {

            NSColor* color = [NSColor colorWithCalibratedRed:_shadowColor.red green:_shadowColor.green blue:_shadowColor.blue alpha:_shadowColor.alpha];
            
            CGContextSetShadowWithColor(context, CGSizeMake(shadowOffset.x/retinaFix, -shadowOffset.y/retinaFix), shadowBlurRadius/retinaFix, [color CGColor]);
        }
        
        if (hasOutline)
        {
            
            CGContextSetTextDrawingMode(context, kCGTextFillStroke);
            CGContextSetLineWidth(context, outlineWidth * 2);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            
            NSColor* color = [NSColor colorWithCalibratedRed:_outlineColor.red green:_outlineColor.green blue:_outlineColor.blue alpha:_outlineColor.alpha];
            
            [effectsString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, effectsString.length)];
            
            [effectsString drawWithRect:NSRectFromCGRect(drawArea) options:NSStringDrawingUsesLineFragmentOrigin];
            
            if (hasShadow)
            {
                CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
                [self drawAttributedString:effectsString inContext:context inRect:drawArea];
            }
            CGContextSetTextDrawingMode(context, kCGTextFill);
        }
    }
	
    [attributedString drawWithRect:NSRectFromCGRect(drawArea) options:NSStringDrawingUsesLineFragmentOrigin];
		CGContextRestoreGState(context);
	
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect (0.0f, 0.0f, POTSize.width, POTSize.height)];
	[image unlockFocus];
    
	unsigned char *data = (unsigned char*) [bitmap bitmapData];  //Use the same buffer to improve the performance.
#endif
    
    CCTexture* texture = NULL;
    
    // Initialize the texture
    if (fullColor)
    {
        // RGBA8888 format
				texture = [[CCTexture alloc] initWithData:data pixelFormat:CCTexturePixelFormat_RGBA8888 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSizeInPixels:dimensions contentScale:[CCDirector sharedDirector].contentScaleFactor];
        [texture setPremultipliedAlpha:YES];
    }
    else
    {
        NSUInteger textureSize = POTSize.width * POTSize.height;
        
        // A8 format (alpha channel only)
        unsigned char* dst = data;
        for(int i = 0; i<textureSize; i++)
            dst[i] = data[i*4+3];
        
        texture = [[CCTexture alloc] initWithData:data pixelFormat:CCTexturePixelFormat_A8 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSizeInPixels:dimensions contentScale:[CCDirector sharedDirector].contentScaleFactor];
        self.shader = [CCShader positionTextureA8ColorShader];
    }
    
#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID
    free(data); // On Mac data is freed by NSBitmapImageRep
#endif
    
	return texture;
}


#pragma mark -
#pragma mark Render Font iOS 5

#if __CC_PLATFORM_IOS
- (BOOL) updateTextureOld
{
    NSString* string = [self string];
    if (!string) return NO;
    
    BOOL useFullColor = NO;
    if (_shadowColor.alpha > 0) useFullColor = YES;
    if (![_fontColor isEqualToColor:[CCColor whiteColor]]) useFullColor = YES;
    if (_outlineColor.alpha > 0 && _outlineWidth > 0) useFullColor = YES;
    
    CCTexture* tex = [self createTextureWithString:string useFullColor:useFullColor];
    if (!tex) return NO;
    
		self.shader = (useFullColor ? [CCShader positionTextureColorShader] : [CCShader positionTextureA8ColorShader]);
        
    // Update texture and content size
	[self setTexture:tex];
	
	CGRect rect = CGRectZero;
	rect.size = [self.texture contentSize];
	[self setTextureRect: rect];
	
	return YES;
}

- (CCTexture*) createTextureWithString:(NSString*) string useFullColor:(BOOL)useFullColor
{
    // Scale everything up by content scale
    CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)string, _fontSize * scale, NULL);
    CGFloat shadowBlurRadius = _shadowBlurRadius * scale;
    CGPoint shadowOffset = ccpMult(self.shadowOffsetInPoints, scale);
    CGFloat outlineWidth = _outlineWidth * scale;
    
    BOOL hasShadow = (_shadowColor.alpha > 0);
    BOOL hasOutline = (_outlineColor.alpha > 0 && _outlineWidth > 0);
    
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    CGFloat scaleFactor = 1;
    
    CGFloat xPadding = 0;
    CGFloat yPadding = 0;
    CGFloat wDrawArea = 0;
    CGFloat hDrawArea = 0;
    
    CGSize originalDimensions = _dimensions;
    originalDimensions.width *= scale;
    originalDimensions.height *= scale;
    
    // Calculate padding
    if (hasShadow)
    {
        xPadding = (shadowBlurRadius + fabs(shadowOffset.x));
        yPadding = (shadowBlurRadius + fabs(shadowOffset.y));
    }
    if (hasOutline)
    {
        xPadding += outlineWidth;
        yPadding += outlineWidth;
    }
    
    CGSize dimensions = originalDimensions;
    
    // Get actual rendered dimensions
    if (dimensions.height == 0)
    {
        // Get dimensions for string without dimensions of string with variable height
        if (dimensions.width > 0)
        {
            dimensions = [self sizeForString:string withFont:font constrainedToWidth:dimensions.width];
        }
        else
        {
            CGSize firstLineSize = [self sizeForString:string withFont:font];
            dimensions = [self sizeForString:string withFont:font constrainedToSize:CGSizeMake(firstLineSize.width,1024)];
        }
        
        wDrawArea = dimensions.width;
        hDrawArea = dimensions.height;
        
        dimensions.width += xPadding * 2;
        dimensions.height += yPadding * 2;
    }
    else if (dimensions.width > 0 && dimensions.height > 0)
    {
        wDrawArea = dimensions.width - xPadding * 2;
        hDrawArea = dimensions.height - yPadding * 2;
        
        // Handle strings with fixed dimensions
        if (_adjustsFontSizeToFit)
        {
            CGFloat fontSize = CTFontGetSize(font);
            CGSize wantedSizeFirstLine =  [self sizeForString:string withFont:font];
            CGSize wantedSize = [self sizeForString:string withFont:font constrainedToSize:CGSizeMake(wantedSizeFirstLine.width,1024)];
            
            CGFloat wScaleFactor = 1;
            CGFloat hScaleFactor = 1;
            if (wantedSize.width > wDrawArea)
            {
                wScaleFactor = wDrawArea/wantedSize.width;
            }
            if (wantedSize.height > hDrawArea)
            {
                hScaleFactor = hDrawArea/wantedSize.height;
            }
            
            if (wScaleFactor < hScaleFactor) scaleFactor = wScaleFactor;
            else scaleFactor = hScaleFactor;
            
            if (scaleFactor != 1)
            {
                CGFloat newFontSize = fontSize * scaleFactor;
                CGFloat minFontSize = _minimumFontSize * scale;
                if (minFontSize && newFontSize < minFontSize) newFontSize = minFontSize;
                CTFontRef newFont = CTFontCreateCopyWithAttributes(font, newFontSize, NULL, NULL);
                CFRelease(font);
                font = newFont;
            }
        }
        
        // Handle vertical alignment
        CGSize actualSize = [self sizeForString:string withFont:font constrainedToSize:CGSizeMake(wDrawArea, 1024)];
    
        if (_verticalAlignment == CCVerticalTextAlignmentBottom)
        {
            yOffset = hDrawArea - actualSize.height;
        }
        else if (_verticalAlignment == CCVerticalTextAlignmentCenter)
        {
            yOffset = (hDrawArea - actualSize.height)/2;
        }
    }
    
    // Handle baseline adjustments
    yOffset += _baselineAdjustment * scaleFactor * scale + yPadding;
    xOffset += xPadding;
    
    // Round dimensions to nearest number that is dividable by 2
    dimensions.width = ceilf(dimensions.width/2)*2;
    dimensions.height = ceilf(dimensions.height/2)*2;

    // get nearest power of two
    CGSize POTSize = CGSizeMake(CCNextPOT(dimensions.width), CCNextPOT(dimensions.height));

    // Mac crashes if the width or height is 0
    if( POTSize.width == 0 )
    POTSize.width = 2;

    if( POTSize.height == 0)
    POTSize.height = 2;

    CGRect drawArea = CGRectMake(xOffset, yOffset, wDrawArea, hDrawArea);

    unsigned char* data = calloc(POTSize.width, POTSize.height * 4);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, POTSize.width, POTSize.height, 8, POTSize.width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    if (!context)
    {
        if (font != NULL) {
            CFRelease(font);
        }
        free(data);
        return NULL;
    }

#if __CC_PLATFORM_IOS
    UIGraphicsPushContext(context);
#endif
    
    // Handle shadow
    if (hasShadow)
    {
        CGContextSetShadowWithColor(context, CGSizeMake(shadowOffset.x, -shadowOffset.y), shadowBlurRadius, _shadowColor.CGColor);
    }
    
    // Handle outline
    if (hasOutline)
    {
        ccColor4F outlineColor = _outlineColor.ccColor4f;
        
        CGContextSetTextDrawingMode(context, kCGTextFillStroke);
        CGContextSetRGBStrokeColor(context, outlineColor.r, outlineColor.g, outlineColor.b, outlineColor.a);
        CGContextSetRGBFillColor(context, outlineColor.r, outlineColor.g, outlineColor.b, outlineColor.a);
        CGContextSetLineWidth(context, outlineWidth * 2);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        
        [self drawString:string withFont:font inContext:context inRect:drawArea];
        
        // Don't draw shadow for main font
        CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
        
        if (hasShadow)
        {
            // Draw again, because shadows overlap
            [self drawString:string withFont:font inContext:context inRect:drawArea];
        }
        
        CGContextSetTextDrawingMode(context, kCGTextFill);
    }
    
    // Handle font color
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    const CGFloat components[] = {_fontColor.red, _fontColor.green, _fontColor.blue, _fontColor.alpha};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGColorSpaceRelease(colorspace);

    CGContextSetFillColorWithColor(context, color);
    CGContextSetStrokeColorWithColor(context, color);
    CGColorRelease(color);

    [self drawString:string withFont:font inContext:context inRect:drawArea];

#if __CC_PLATFORM_IOS
    UIGraphicsPopContext();
#endif
    CGContextRelease(context);

    CCTexture* texture = NULL;

    // Initialize the texture
    if (useFullColor)
    {
        // RGBA8888 format
        texture = [[CCTexture alloc] initWithData:data pixelFormat:CCTexturePixelFormat_RGBA8888 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSizeInPixels:dimensions contentScale:[CCDirector sharedDirector].contentScaleFactor];
        [texture setPremultipliedAlpha:YES];
    }
    else
    {
        NSUInteger textureSize = POTSize.width * POTSize.height;
        
        // A8 format (alpha channel only)
        unsigned char* dst = data;
        for(int i = 0; i<textureSize; i++)
            dst[i] = data[i*4+3];
        
        texture = [[CCTexture alloc] initWithData:data pixelFormat:CCTexturePixelFormat_A8 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSizeInPixels:dimensions contentScale:[CCDirector sharedDirector].contentScaleFactor];
        self.shader = [CCShader positionTextureA8ColorShader];
    }

    free(data);
    CFRelease(font);

    return texture;
}

#endif

#pragma mark -
#pragma mark Handle HTML

#if __CC_PLATFORM_MAC
- (void) setHTML:(NSString *)html
{
    NSData* data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    self.attributedString = [[NSAttributedString alloc] initWithHTML:data documentAttributes:NULL];
}
#endif



#pragma mark Class functions

+ (NSString*) registerCustomTTF:(NSString *)fontFile
{
    // Do not register a font if it has already been registered
    if (!ccLabelTTF_registeredFonts)
    {
        ccLabelTTF_registeredFonts = [[NSMutableDictionary alloc] init];
    }
    
    if ([ccLabelTTF_registeredFonts objectForKey:fontFile]) return [ccLabelTTF_registeredFonts objectForKey:fontFile];
    
    
    // Register with font manager
    if ([[fontFile lowercaseString] hasSuffix:@".ttf"] || [[fontFile lowercaseString] hasSuffix:@".otf"])
    {
        // This is a file, register font with font manager
        NSString* fontPath = [[CCFileUtils sharedFileUtils] fullPathForFilename:fontFile];
        assert(fontPath != nil);
        NSURL* fontURL = [NSURL fileURLWithPath:fontPath];
        CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontURL, kCTFontManagerScopeProcess, NULL);
        
        CFArrayRef descriptors = CTFontManagerCreateFontDescriptorsFromURL((__bridge CFURLRef)fontURL);
        if (!descriptors || CFArrayGetCount(descriptors)<1) {
            return nil;
        }
        CTFontDescriptorRef descriptor = CFArrayGetValueAtIndex(descriptors, 0);
        NSString * fontName = (__bridge NSString *)CTFontDescriptorCopyAttribute(descriptor, kCTFontFamilyNameAttribute);
        CFRelease(descriptor);
        [ccLabelTTF_registeredFonts setObject:fontName forKey:fontFile];
        return fontName;
    }
    return nil;
}

@end
