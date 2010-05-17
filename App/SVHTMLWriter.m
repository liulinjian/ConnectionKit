//
//  SVTextDOMControllerHTMLWriter.m
//  Sandvox
//
//  Created by Mike on 19/03/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "SVHTMLWriter.h"


@implementation SVHTMLWriter

- (void)dealloc
{
    [self flush];
    OBASSERT(!_buffer); // flushing should clear the buffer
    
    [super dealloc];
}

@synthesize delegate = _delegate;

- (BOOL)HTMLWriter:(KSHTMLWriter *)writer writeDOMElement:(DOMElement *)element;
{
    return [[self delegate] HTMLWriter:writer writeDOMElement:element];
}

@end


#pragma mark -


@interface SVHTMLBuffer : NSObject <KSStringWriter>
{
@private
    NSMutableString *_string;
    SVHTMLBuffer    *_buffer;
}

- (id)initWithExistingBuffer:(SVHTMLBuffer *)buffer;
- (SVHTMLBuffer *)subbuffer;
- (NSMutableString *)mutableString;
@end


#pragma mark -


@implementation SVHTMLWriter (Buffering)

- (void)beginBuffering;
{
    SVHTMLBuffer *buffer = [[SVHTMLBuffer alloc] initWithExistingBuffer:_buffer];
    [_buffer release];
    _buffer = buffer;
}

- (void)discardBuffer;  // only discards the most recent buffer. If there's a lower one in the stack, that is restored
{
    SVHTMLBuffer *buffer = [[_buffer subbuffer] retain];
    [_buffer release]; _buffer = buffer;
}

- (void)flushBuffer:(SVHTMLBuffer *)buffer;
{
    // Is there a subbuffer? If so, flush that one first
    SVHTMLBuffer *subbuffer = [buffer subbuffer];
    if (subbuffer) [self flushBuffer:subbuffer];
    
    NSMutableString *string = [buffer mutableString];
    [[self stringWriter] writeString:string];
    [string setString:@""];
}

- (void)flush;
{
    _flushOnNextWrite = NO;
    
    // Flush buffers
    if (_buffer)
    {
        SVHTMLBuffer *buffer = _buffer;
        _buffer = nil;
        [self flushBuffer:buffer];
        [buffer release];
    }
    
    
    [super flush];
}

- (void)flushOnNextWrite;
{
    _flushOnNextWrite = YES;
}

#pragma mark Primitive Writing

- (void)writeString:(NSString *)string
{
    if (_flushOnNextWrite) [self flush];
    
    // Do the writing
    [super writeString:string];
}

- (id <KSStringWriter>)stringWriter;
{
    return (_buffer ? _buffer : [super stringWriter]);
}

@end


#pragma mark -


@implementation SVHTMLBuffer

- (id)initWithExistingBuffer:(SVHTMLBuffer *)buffer;
{
    [self init];
    
    _string = [[NSMutableString alloc] init];
    _buffer = [buffer retain];
    
    return self;
}

- (void)dealloc
{
    [_string release];
    [_buffer release];
    
    [super dealloc];
}

- (SVHTMLBuffer *)subbuffer; { return _buffer; }

- (NSMutableString *)mutableString; { return _string; }

- (void)writeString:(NSString *)string;
{
    [_string appendString:string];
}

- (void)close; { }

@end
