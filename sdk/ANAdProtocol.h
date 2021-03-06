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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ANAdFetcher;
@class ANLocation;

typedef enum _ANGender
{
    UNKNOWN,
    MALE,
    FEMALE
} ANGender;

// ANAdProtocol defines the properties and methods that are common to
// *all* ad types.  It can be understood as a toolkit for implementing
// ad types (It's used in the implementation of both banners and
// interstitials by the SDK).  If you wanted to, you could implement
// your own ad type using this protocol.

@protocol ANAdProtocol <NSObject>

@required
// An AppNexus placement ID.  A placement ID is a numeric ID that's
// associated with a place where ads can be shown.  In our
// implementations of banner and interstitial ad views, we associate
// each ad view with a placement ID.
@property (nonatomic, readwrite, strong) NSString *placementId;

// Determines whether the ad, when clicked, will open the device's
// native browser.
@property (nonatomic, readwrite, assign) BOOL opensInNativeBrowser;

// Whether the ad view should display PSAs if there are no ads
// available from the server.
@property (nonatomic, readwrite, assign) BOOL shouldServePublicServiceAnnouncements;

// The user's location.  See ANLocation.h in this directory for
// details.
@property (nonatomic, readwrite, strong) ANLocation *location;

// The reserve price is the minimum bid amount you'll accept to show
// an ad.  Use this with caution, as it can drastically reduce fill
// rates (i.e., you will make less money).
@property (nonatomic, readwrite, assign) CGFloat reserve;

// The user's age.  This can contain a numeric age, a birth year, or a
// hyphenated age range.  For example, "56", "1974", or "25-35".
@property (nonatomic, readwrite, strong) NSString *age;

// The user's gender.  See the _ANGENDER struct above for details.
@property (nonatomic, readwrite, assign) ANGender gender;

// Used to pass custom keywords across different mobile ad server and
// SDK integrations.
@property (nonatomic, readwrite, strong) NSMutableDictionary *customKeywords;

// Set the ad view's location.  This allows ad buyers to do location
// targeting, which can increase spend.
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy;

// These methods add and remove custom keywords to and from the
// customKeywords dictionary.
- (void)addCustomKeywordWithKey:(NSString *)key value:(NSString *)value;
- (void)removeCustomKeywordWithKey:(NSString *)key;

#pragma mark Deprecated Properties

// This property is deprecated; use opensInNativeBrowser instead.
@property (nonatomic, readwrite, assign) BOOL clickShouldOpenInBrowser DEPRECATED_ATTRIBUTE;

@end

// The definition of the `ANAdDelegate' protocol includes methods
// which can be implemented by either type of ad.  Though these
// methods are listed here as optional, specific ad types may require
// them.  For example, interstitial ads require that `adDidReceiveAd'
// be implemented.
@protocol ANAdDelegate <NSObject>

@optional
// Sent when the ad content has been successfully retrieved from the
// server.
- (void)adDidReceiveAd:(id<ANAdProtocol>)ad;

// Sent when the ad request to the server has failed.
- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error;

// Sent when the ad is clicked by the user.
- (void)adWasClicked:(id<ANAdProtocol>)ad;

// Sent when the ad view is about to close. 
- (void)adWillClose:(id<ANAdProtocol>)ad;

// Sent when the ad view has finished closing.
- (void)adDidClose:(id<ANAdProtocol>)ad;

// Sent when the ad is clicked, and the SDK is about to open inside
// the in-SDK browser (a WebView).  If you would prefer that ad clicks
// open the native browser instead, set `opensInNativeBrowser' to
// true.
- (void)adWillPresent:(id<ANAdProtocol>)ad;

// Sent when the ad has finished being viewed using the in-SDK
// browser.
- (void)adDidPresent:(id<ANAdProtocol>)ad;

// Sent when the ad is about to leave the app; this can happen if you
// have `opensInNativeBrowser' set to true, for example.
- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad;

@end
