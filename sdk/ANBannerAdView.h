/*   Copyright 2013 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "ANAdView.h"

@protocol ANBannerAdViewDelegate;

#pragma mark Example implementation

// This view displays banner ads.  A simple implementation that shows
// a 300x50 ad is:
//
//  CGSize size = CGSizeMake(300, 50);
//  
//  // Create the banner ad view and add it as a subview
//  ANBannerAdView *banner = [ANBannerAdView adViewWithFrame:rect placementId:@"1326299" adSize:size];
//  banner.rootViewController = self;
//  [self.view addSubview:banner];
//
//  // Load an ad!
//  [banner loadAd];
//  [banner release]; // Only required for non-ARC projects
@interface ANBannerAdView : ANAdView

// Delegate object that receives notifications from this
// ANBannerAdView.
@property (nonatomic, readwrite, weak) id<ANBannerAdViewDelegate> delegate;

// Required reference to the root view controller.  Used as shown in
// the example above to set the banner ad view's controller to your
// own view controller implementation.
@property (nonatomic, readwrite, assign) UIViewController *rootViewController;

// Represents the width and height of the ad view.  In order for ads
// to display correctly, you must verify that your AppNexus placement
// is a ``sizeless'' placement.  If you are seeing ads of a fixed size
// being squeezed into differently-sized views, you probably do not
// have a sizeless placement.
@property (nonatomic, readwrite, assign) CGSize adSize;

// Autorefresh interval.  Default interval is 30.0; the minimum
// allowed is 15.0.  To disable autorefresh, set to 0.
@property (nonatomic, readwrite, assign) NSTimeInterval autoRefreshInterval;

#pragma mark Creating an ad view and loading an ad

// You can use either of the initialization methods below.
// adViewWithFrame handles calling initWithFrame for you, but it's
// there if you need to use it directly.

// Initializes an ad view with the specified frame (this frame must be
// smaller than the view's size).  Used internally by adViewWithFrame,
// so you may want to use that instead, unless you prefer to manage
// this manually.
- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId;
- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size;

// Initializes an ad view.  These are autoreleased constructors of the
// above initializers that will handle the frame initialization for
// you.  (For usage, see the example at the top of this file).
+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId;
+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size;

#pragma mark Loading an ad

// Loads a single ad into this ad view.  If autorefresh is not set to
// 0, this will also start a timer to refresh the banner
// automatically.
- (void)loadAd;

// Allows the frame containing the ad to animate (resize momentarily).
// This allows for a class of ads known as "expandables."  In order to
// show an expandable ad, set the animated flag to true.
- (void)setFrame:(CGRect)frame animated:(BOOL)animated;

@end

#pragma mark ANBannerAdViewDelegate

// See ANAdDelegate for common delegate methods.  The
// ANBannerAdViewDelegate-specific methods are defined here.
@protocol ANBannerAdViewDelegate <ANAdDelegate>

@optional
// Sent just before the adView will resize to fill a larger part of
// the screen.  This is in response to a user interacting with an ad
// that resizes itself.
- (void)bannerAdView:(ANBannerAdView *)adView willResizeToFrame:(CGRect)frame;

// Sent after the adView has resized.
- (void)bannerAdViewDidResize:(ANBannerAdView *)adView;

@end
