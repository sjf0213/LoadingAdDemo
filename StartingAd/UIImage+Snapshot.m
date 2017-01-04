/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "UIImage+Snapshot.h"

@implementation UIApplication (StrictKeyWindow)

- (UIWindow *)fb_strictKeyWindow
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) {
        [NSException raise:@"FBSnapshotTestCaseNilKeyWindowException"
                    format:@"Snapshot tests must be hosted by an application with a key window. Please ensure your test"
         " host sets up a key window at launch (either via storyboards or programmatically) and doesn't"
         " do anything to remove it while snapshot tests are running."];
    }
    return keyWindow;
}

@end

@implementation UIImage (Snapshot)

+ (UIImage *)fb_imageForLayer:(CALayer *)layer
{
  CGRect bounds = layer.bounds;
  NSAssert1(CGRectGetWidth(bounds), @"Zero width for layer %@", layer);
  NSAssert1(CGRectGetHeight(bounds), @"Zero height for layer %@", layer);

  UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  NSAssert1(context, @"Could not generate context for layer %@", layer);
  CGContextSaveGState(context);
  [layer layoutIfNeeded];
  [layer renderInContext:context];
  CGContextRestoreGState(context);

  UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return snapshot;
}

+ (UIImage *)fb_imageForViewLayer:(UIView *)view
{
  [view layoutIfNeeded];
  return [self fb_imageForLayer:view.layer];
}

+ (UIImage *)fb_imageForView:(UIView *)view
{
  CGRect bounds = view.bounds;
  NSAssert1(CGRectGetWidth(bounds), @"Zero width for view %@", view);
  NSAssert1(CGRectGetHeight(bounds), @"Zero height for view %@", view);

  // If the input view is already a UIWindow, then just use that. Otherwise wrap in a window.
  UIWindow *window = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
  BOOL removeFromSuperview = NO;
  if (!window) {
    window = [[UIApplication sharedApplication] fb_strictKeyWindow];
  }

  if (!view.window && view != window) {
    [window addSubview:view];
    removeFromSuperview = YES;
  }

  UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
  [view layoutIfNeeded];
  [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];

  UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  if (removeFromSuperview) {
    [view removeFromSuperview];
  }

  return snapshot;
}

@end
