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

#import "AdSettings.h"
#import "ANLogging.h"

@implementation AdSettings

#define CLASS_NAME @"AdSettings"

#define ALL_SETTINGS_KEY @"ANXAdSettings_All"
#define AD_TYPE_KEY @"AdType"
#define AD_WIDTH_KEY @"AdWidth"
#define AD_HEIGHT_KEY @"AdHeight"
#define ALLOW_PSA_KEY @"AllowPSA"
#define BROWSER_TYPE_KEY @"BrowserType"
#define PLACEMENT_ID_KEY @"PlacementID"
#define REFRESH_RATE_KEY @"RefreshRate"
#define BACKGROUND_COLOR_KEY @"BackgroundColor"
#define MEMBER_ID_KEY @"MemberID"
#define DONGLE_KEY @"Dongle"

- (id)init {
    NSDictionary *settingsFromUserDefaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_SETTINGS_KEY];
    if (!settingsFromUserDefaults) { // If there are no saved settings
        self = [self initWithDefaultSettings]; // Initiate With Default Settings
    } else {
        self = [self initFromPropertyList:settingsFromUserDefaults]; // Initiate With Saved Settings
    }
    return self;
}

- (void)synchronize {
    [[NSUserDefaults standardUserDefaults] setObject:[self asPropertyList] forKey:ALL_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)asPropertyList {
    return @{AD_TYPE_KEY:@(self.adType),
             AD_WIDTH_KEY:@(self.bannerWidth),
             AD_HEIGHT_KEY:@(self.bannerHeight),
             ALLOW_PSA_KEY:@(self.allowPSA), BROWSER_TYPE_KEY:@(self.browserType),
             PLACEMENT_ID_KEY:@(self.placementID),
             BACKGROUND_COLOR_KEY:self.backgroundColor,
             MEMBER_ID_KEY:@(self.memberID),
             DONGLE_KEY:self.dongle,
             REFRESH_RATE_KEY:@(self.refreshRate)};
}

- (id)initFromPropertyList:(id)plist {
    self = [super init];
    if (self) {
        if ([plist isKindOfClass:[NSDictionary class]]) {
            NSDictionary *settingsDict = (NSDictionary *)plist;
            /*
                General Properties
             */
            _adType = [settingsDict[AD_TYPE_KEY] intValue];
            _allowPSA = [settingsDict[ALLOW_PSA_KEY] boolValue];
            _browserType = [settingsDict[BROWSER_TYPE_KEY] intValue];
            _placementID = [settingsDict[PLACEMENT_ID_KEY] intValue];
            
            /*
                Banner Properties
             */
            _bannerWidth = [settingsDict[AD_WIDTH_KEY] intValue];
            _bannerHeight = [settingsDict[AD_HEIGHT_KEY] intValue];
            _refreshRate = [settingsDict[REFRESH_RATE_KEY] intValue];
            
            /*
                Interstitial Properties
             */
            _backgroundColor = settingsDict[BACKGROUND_COLOR_KEY];
            
            /*
                Debug Properties
             */
            _memberID = [settingsDict[MEMBER_ID_KEY] intValue];
            _dongle = settingsDict[DONGLE_KEY];
        }
    }
    return self;
}

- (id)initWithDefaultSettings {
    self = [super init];
    if (self) {
        /*
            General properties
         */
        _adType = DEFAULT_AD_TYPE;
        _allowPSA = DEFAULT_ALLOW_PSA;
        _browserType = DEFAULT_BROWSER_TYPE;
        _placementID = DEFAULT_PLACEMENT_ID;
        
        /*
         Banner Properties
         */
        _bannerWidth = DEFAULT_BANNER_WIDTH;
        _bannerHeight = DEFAULT_BANNER_HEIGHT;
        _refreshRate = DEFAULT_REFRESH_RATE;
        
        /*
            Interstitial Properties
         */
        
        _backgroundColor = DEFAULT_BACKGROUD_COLOR;
        
        /*
            Debug Properties
         */
        _memberID = DEFAULT_MEMBER_ID;
        _dongle = DEFAULT_DONGLE;
    }
    return self;
}

- (void)setAdType:(AdType)adType {
    ANLogDebug(@"Setting Ad Type To Value: %d", adType);
    _adType = adType;
    [self synchronize];
}

- (void)setBannerWidth:(int)adWidth {
    ANLogDebug(@"Setting Ad Width To Value: %d", adWidth);
    _bannerWidth = adWidth;
    [self synchronize];
}

- (void)setBannerHeight:(int)adHeight {
    ANLogDebug(@"Setting Ad Height To Value: %d", adHeight);
    _bannerHeight = adHeight;
    [self synchronize];
}

- (void)setAllowPSA:(BOOL)allowPSA {
    ANLogDebug(@"Setting Allow PSA To Value: %d", allowPSA);
    _allowPSA = allowPSA;
    [self synchronize];
}

- (void)setBrowserType:(BrowserType)browserType {
    ANLogDebug(@"Setting Browser Type To Value: %d", browserType);
    _browserType = browserType;
    [self synchronize];
}

- (void)setPlacementID:(int)placementID {
    _placementID = placementID;
    [self synchronize];
}

- (void)setBackgroundColor:(NSString *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self synchronize];
}

- (void)setMemberID:(int)memberID {
    _memberID = memberID;
    [self synchronize];
}

- (void)setDongle:(NSString *)dongle {
    _dongle = dongle;
    [self synchronize];
}

- (void)setRefreshRate:(int)refreshRate {
    _refreshRate = refreshRate;
    [self synchronize];
}

+ (BOOL)backgroundColorIsValid:(NSString *)backgroundColor {
    // Expects a valid hex value in the format AARRGGBB or 0xAARRGGBB
    NSUInteger stringLength = [backgroundColor length];
    if (stringLength != 8 && stringLength != 10 && stringLength != 0) return NO;
    if (!stringLength) return YES;
    NSScanner *scanner = [NSScanner scannerWithString:backgroundColor];
    unsigned int scannedValue;
    BOOL isValid = [scanner scanHexInt:&scannedValue];
    
    ANLogDebug(@"%@ backgroundColorIsValid | Is valid hex value: %d", CLASS_NAME, isValid);
    ANLogDebug(@"%@ backgroundColorIsValid | Hex value: %d", CLASS_NAME, scannedValue);
    
    return isValid;
}

@end
