//
//  CCEffectRenderer.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/21/14.
//
//

#import "CCEffectRenderer.h"
#import "CCConfiguration.h"
#import "CCDirector.h"
#import "CCEffect.h"
#import "CCEffectStack.h"
#import "CCTexture.h"
#import "ccUtils.h"

#import "CCTexture_Private.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS

@interface CCEffectRenderTarget : NSObject

@property (nonatomic, readonly) CCTexture *texture;
@property (nonatomic, readonly) GLuint FBO;
@property (nonatomic, readonly) GLuint depthRenderBuffer;
@property (nonatomic, readonly) BOOL glResourcesAllocated;

@end

@implementation CCEffectRenderTarget

- (id)init
{
    if((self = [super init]))
    {
    }
    return self;
}

- (void)dealloc
{
    if (self.glResourcesAllocated)
    {
        [self destroyGLResources];
    }
}

- (BOOL)setupGLResourcesWithSize:(CGSize)size
{
    NSAssert(!_glResourcesAllocated, @"");
    
    glPushGroupMarkerEXT(0, "CCEffectRenderTarget: allocateRenderTarget");
    
	// Textures may need to be a power of two
	NSUInteger powW;
	NSUInteger powH;
    
	if( [[CCConfiguration sharedConfiguration] supportsNPOT] )
    {
		powW = size.width;
		powH = size.height;
	}
    else
    {
		powW = CCNextPOT(size.width);
		powH = CCNextPOT(size.height);
	}
    
    static const CCTexturePixelFormat kRenderTargetDefaultPixelFormat = CCTexturePixelFormat_RGBA8888;
    static const float kRenderTargetDefaultContentScale = 1.0f;
    
    // Create a new texture object for use as the color attachment of the new
    // FBO.
	_texture = [[CCTexture alloc] initWithData:nil pixelFormat:kRenderTargetDefaultPixelFormat pixelsWide:powW pixelsHigh:powH contentSizeInPixels:size contentScale:kRenderTargetDefaultContentScale];
	[_texture setAliasTexParameters];
	
    // Save the old FBO binding so it can be restored after we create the new
    // one.
	GLint oldFBO;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
    
	// Generate a new FBO and bind it so it can be modified.
	glGenFramebuffers(1, &_FBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
    
	// Associate texture with FBO
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture.name, 0);
    
	// Check if it worked (probably worth doing :) )
	NSAssert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Could not attach texture to framebuffer");
    
    // Restore the old FBO binding.
	glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
	
	CC_CHECK_GL_ERROR_DEBUG();
	glPopGroupMarkerEXT();
    
    _glResourcesAllocated = YES;
    return YES;
}

- (void)destroyGLResources
{
    NSAssert(_glResourcesAllocated, @"");
    glDeleteFramebuffers(1, &_FBO);
    if (_depthRenderBuffer)
    {
        glDeleteRenderbuffers(1, &_depthRenderBuffer);
    }
    
    _texture = nil;
    
    _glResourcesAllocated = NO;
}

@end


@interface CCEffectRenderer ()

@property (nonatomic, strong) NSMutableArray *allRenderTargets;
@property (nonatomic, strong) NSMutableArray *freeRenderTargets;
@property (nonatomic, assign) GLKVector4 oldViewport;
@property (nonatomic, assign) GLint oldFBO;
@property (nonatomic, strong) CCTexture *outputTexture;

@end


@implementation CCEffectRenderer

-(id)init
{
    if((self = [super init]))
    {
        _allRenderTargets = [[NSMutableArray alloc] init];
        _freeRenderTargets = [[NSMutableArray alloc] init];
        _contentSize = CGSizeMake(1.0f, 1.0f);
        _contentScale = [CCDirector sharedDirector].contentScaleFactor;
    }
    return self;
}

-(void)dealloc
{
    [self destroyAllRenderTargets];
}

-(void)drawSprite:(CCSprite *)sprite withEffect:(CCEffect *)effect renderer:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
    if (effect && ![effect prepareForRendering])
    {
        NSAssert(0, @"Effect preparation failed.");
        return;
    }

    [self freeAllRenderTargets];
    
    GLKMatrix4 projection = GLKMatrix4MakeOrtho(0.0f, _contentSize.width, _contentSize.height, 0.0f, -1024.0f, 1024.0f);
    
    CCEffectRenderTarget *previousPassRT = nil;

    for(int i = 0; i < effect.renderPassesRequired; i++)
    {
        BOOL lastPass = (i == (effect.renderPassesRequired - 1));
        BOOL directRendering = lastPass && effect.supportsDirectRendering;
        
        CCTexture *previousPassTexture = nil;
        if (previousPassRT)
        {
            previousPassTexture = previousPassRT.texture;
        }
        else
        {
            previousPassTexture = sprite.texture;
        }
        
        CCEffectRenderPass* renderPass = [effect renderPassAtIndex:i];
        renderPass.renderer = renderer;
        renderPass.renderPassId = i;
        renderPass.verts = *(sprite.vertexes);
        renderPass.blendMode = [CCBlendMode premultipliedAlphaMode];
        renderPass.needsClear = !directRendering;
        
        CCEffectRenderTarget *rt = nil;
        
        [renderer pushGroup];
        if (directRendering)
        {
            renderPass.transform = *transform;
            
            renderPass.beginBlock(previousPassTexture);
            renderPass.updateBlock();
            renderPass.endBlock();
        }
        else
        {
            renderPass.transform = projection;
            
            CGSize rtSize = CGSizeMake(_contentSize.width * _contentScale, _contentSize.height * _contentScale);
            rt = [self renderTargetWithSize:rtSize];
            
            renderPass.beginBlock(previousPassTexture);
            [self bindRenderTarget:rt withRenderer:renderer];
            renderPass.updateBlock();
            [self restoreRenderTargetWithRenderer:renderer];
            renderPass.endBlock();
        }
        [renderer popGroupWithDebugLabel:[NSString stringWithFormat:@"CCEffectRenderer: %@: Pass %d", effect.debugName, i] globalSortOrder:0];
        
        previousPassRT = rt;
    }
    
    _outputTexture = previousPassRT.texture;
}

- (void)bindRenderTarget:(CCEffectRenderTarget *)rt withRenderer:(CCRenderer *)renderer
{
    CGSize pixelSize = rt.texture.contentSizeInPixels;
    GLuint fbo = rt.FBO;
    
    [renderer enqueueBlock:^{
        glGetFloatv(GL_VIEWPORT, _oldViewport.v);
        glViewport(0, 0, pixelSize.width, pixelSize.height );
        
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
        glBindFramebuffer(GL_FRAMEBUFFER, fbo);
        
    } globalSortOrder:NSIntegerMin debugLabel:@"CCEffectRenderer: Bind FBO" threadSafe:NO];
}

- (void)restoreRenderTargetWithRenderer:(CCRenderer *)renderer
{
    [renderer enqueueBlock:^{
        glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
        glViewport(_oldViewport.v[0], _oldViewport.v[1], _oldViewport.v[2], _oldViewport.v[3]);
    } globalSortOrder:NSIntegerMax debugLabel:@"CCEffectRenderer: Restore FBO" threadSafe:NO];
    
}

- (CCEffectRenderTarget *)renderTargetWithSize:(CGSize)size
{
    // If there is a free render target available for use, return that one. If
    // not, create a new one and return that.
    CCEffectRenderTarget *rt = nil;
    if (_freeRenderTargets.count)
    {
        rt = [_freeRenderTargets lastObject];
        [_freeRenderTargets removeLastObject];
    }
    else
    {
        rt = [[CCEffectRenderTarget alloc] init];
        [rt setupGLResourcesWithSize:size];
        [_allRenderTargets addObject:rt];
    }
    return rt;
}

- (void)destroyAllRenderTargets
{
    // Destroy all allocated render target objects and the associated GL resources.
    for (CCEffectRenderTarget *rt in _allRenderTargets)
    {
        [rt destroyGLResources];
    }
    [_allRenderTargets removeAllObjects];
    [_freeRenderTargets removeAllObjects];
}

- (void)freeRenderTarget:(CCEffectRenderTarget *)rt
{
    // Put the supplied render target back into the free list. If it's already there
    // them somebody is doing something wrong.
    NSAssert(![_freeRenderTargets containsObject:rt], @"Double freeing a render target!");
    [_freeRenderTargets addObject:rt];
}

- (void)freeAllRenderTargets
{
    // Reset the free render target list to contain all allocated render targets.
    [_freeRenderTargets removeAllObjects];
    [_freeRenderTargets addObjectsFromArray:_allRenderTargets];
}

@end
#endif
