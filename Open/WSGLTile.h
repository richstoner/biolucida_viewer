//////////////////////////////////////////////////////////////////////////////////////
//
//    This software is Copyright © 2013 WholeSlide, Inc. All Rights Reserved.
//
//    Permission to copy, modify, and distribute this software and its documentation
//    for educational, research and non-profit purposes, without fee, and without a
//    written agreement is hereby granted, provided that the above copyright notice,
//    this paragraph and the following three paragraphs appear in all copies.
//
//    Permission to make commercial use of this software may be obtained by contacting:
//
//    Rich Stoner, WholeSlide, Inc
//    8070 La Jolla Shores Dr, #410
//    La Jolla, CA 92037
//    stoner@wholeslide.com
//
//    This software program and documentation are copyrighted by WholeSlide, Inc. The
//    software program and documentation are supplied "as is", without any
//    accompanying services from WholeSlide, Inc. WholeSlide, Inc does not warrant
//    that the operation of the program will be uninterrupted or error-free. The
//    end-user understands that the program was developed for research purposes and is
//    advised not to rely exclusively on the program for any reason.
//
//    IN NO EVENT SHALL WHOLESLIDE, INC BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
//    SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING
//    OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF WHOLESLIDE,INC
//    HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. WHOLESLIDE,INCSPECIFICALLY
//    DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED
//    HEREUNDER IS ON AN "AS IS" BASIS, AND WHOLESLIDE,INC HAS NO OBLIGATIONS TO
//    PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS UNLESS
//    OTHERWISE STATED.
//
//////////////////////////////////////////////////////////////////////////////////////
//
//  WSGLTile.h
//  Open
//
//  Created by Rich Stoner on 11/14/13.
//
//

#import <Foundation/Foundation.h>

@interface WSGLTile : WSGenericTiledImage

@property(nonatomic, strong) EAGLContext* context;
@property(nonatomic, strong) GLKTextureInfo* texture;
@property(nonatomic, assign, readwrite) int level; // zoom level

- (void) prepareTileWithContext:(EAGLContext*) theContext;
- (void) updateMVMatrixWithViewMatrix:(GLKMatrix4) theViewMatrix;
- (void) drawWithEffect:(GLKBaseEffect*) theEffect;
- (void) drawBackground:(GLKBaseEffect*) theEffect;


@end
