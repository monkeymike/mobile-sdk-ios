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

#import "ANAdRequestUrl.h"

#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANReachability.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface ANAdRequestUrl()
@property (nonatomic, readwrite, weak) id<ANAdFetcherDelegate> adFetcherDelegate;
@end

@implementation ANAdRequestUrl

+ (NSURL *)buildRequestUrlWithAdFetcherDelegate:(id<ANAdFetcherDelegate>)adFetcherDelegate
                                  baseUrlString:(NSString *)baseUrlString {
    ANAdRequestUrl *adRequestUrl = [[[self class] alloc] init];
    adRequestUrl.adFetcherDelegate = adFetcherDelegate;
    return [adRequestUrl buildRequestUrlWithBaseUrlString:baseUrlString];
}

- (NSURL *)buildRequestUrlWithBaseUrlString:(NSString *)baseUrlString {
    baseUrlString = [baseUrlString stringByAppendingString:[self placementIdParameter]];
	baseUrlString = [baseUrlString stringByAppendingString:ANUdidParameter()];
    baseUrlString = [baseUrlString stringByAppendingString:[self dontTrackEnabledParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self deviceMakeParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self deviceModelParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self carrierMccMncParameters]];
    baseUrlString = [baseUrlString stringByAppendingString:[self applicationIdParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self firstLaunchParameter]];
    
    baseUrlString = [baseUrlString stringByAppendingString:[self locationParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self userAgentParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self orientationParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self connectionTypeParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self devTimeParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self languageParameter]];
    
    baseUrlString = [baseUrlString stringByAppendingString:[self nativeBrowserParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self psaAndReserveParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self ageParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self genderParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self customKeywordsParameter]];
    
    baseUrlString = [baseUrlString stringByAppendingString:[self jsonFormatParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self supplyTypeParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self sdkVersionParameter]];
    
    baseUrlString = [baseUrlString stringByAppendingString:[self extraParameters]];
    
	return [NSURL URLWithString:baseUrlString];
}

- (NSString *)URLEncodingFrom:(NSString *)originalString {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)originalString,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]<>",
                                                                                 kCFStringEncodingUTF8);
}

- (NSString *)placementIdParameter {
    NSString *placementId = [self.adFetcherDelegate placementId];

    if ([placementId length] < 1) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"id=%@", [self URLEncodingFrom:placementId]];
}

- (NSString *)dontTrackEnabledParameter {
    return ANAdvertisingTrackingEnabled() ? @"" : @"&dnt=1";
}

- (NSString *)deviceMakeParameter {
    return @"&devmake=Apple";
}

- (NSString *)deviceModelParameter {
    return [NSString stringWithFormat:@"&devmodel=%@", [self URLEncodingFrom:ANDeviceModel()]];
}

- (NSString *)applicationIdParameter {
    NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return [NSString stringWithFormat:@"&appid=%@", appId];
}

- (NSString *)firstLaunchParameter {
    return isFirstLaunch() ? @"&firstlaunch=true" : @"";
}

- (NSString *)carrierMccMncParameters {
    NSString *param = @"";
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    
    if ([[carrier carrierName] length] > 0) {
        param = [param stringByAppendingString:
                 [NSString stringWithFormat:@"&carrier=%@",
                  [self URLEncodingFrom:[carrier carrierName]]]];
    }
    
    if ([[carrier mobileCountryCode] length] > 0) {
        param = [param stringByAppendingString:
                 [NSString stringWithFormat:@"&mcc=%@",
                  [self URLEncodingFrom:[carrier mobileCountryCode]]]];
    }
    
    if ([[carrier mobileNetworkCode] length] > 0) {
        param = [param stringByAppendingString:
                 [NSString stringWithFormat:@"&mnc=%@",
                  [self URLEncodingFrom:[carrier mobileNetworkCode]]]];
    }
    
    return param;
}

- (NSString *)connectionTypeParameter {
    ANReachability *reachability = [ANReachability reachabilityForInternetConnection];
    ANNetworkStatus status = [reachability currentReachabilityStatus];
    return status == ANNetworkStatusReachableViaWiFi ? @"&connection_type=wifi" : @"&connection_type=wan";
}

- (NSString *)locationParameter {
    ANLocation *location = [self.adFetcherDelegate location];
    NSString *locationParameter = @"";
    
    if (location) {
        NSDate *locationTimestamp = location.timestamp;
        NSTimeInterval ageInSeconds = -1.0 * [locationTimestamp timeIntervalSinceNow];
        NSInteger ageInMilliseconds = (NSInteger)(ageInSeconds * 1000);
        
        locationParameter = [locationParameter
                             stringByAppendingFormat:@"&loc=%f,%f&loc_age=%ld&loc_prec=%f",
                             location.latitude, location.longitude,
                             (long)ageInMilliseconds, location.horizontalAccuracy];
    }
    
    return locationParameter;
}

- (NSString *)orientationParameter {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    return [NSString stringWithFormat:@"&orientation=%@",
            UIInterfaceOrientationIsLandscape(orientation) ? @"h" : @"v"];
}

- (NSString *)userAgentParameter {
    return [NSString stringWithFormat:@"&ua=%@",
            [self URLEncodingFrom:ANUserAgent()]];
}

- (NSString *)languageParameter {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return ([language length] > 0) ? [NSString stringWithFormat:@"&language=%@", language] : @"";
}

- (NSString *)devTimeParameter {
    int timeInMiliseconds = (int) [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"&devtime=%d", timeInMiliseconds];
}

- (NSString *)nativeBrowserParameter {
    return [NSString stringWithFormat:@"&native_browser=%d", self.adFetcherDelegate.opensInNativeBrowser];
}

- (NSString *)psaAndReserveParameter {
    BOOL shouldServePsas = [self.adFetcherDelegate shouldServePublicServiceAnnouncements];
    CGFloat reserve = [self.adFetcherDelegate reserve];
    if (reserve > 0.0f) {
        NSString *reserveParameter = [self URLEncodingFrom:[NSString stringWithFormat:@"%f", reserve]];
        return [NSString stringWithFormat:@"&psa=0&reserve=%@", reserveParameter];
    } else {
        return shouldServePsas ? @"&psa=1" : @"&psa=0";
    }
}

- (NSString *)ageParameter {
    NSString *ageValue = [self.adFetcherDelegate age];
    if ([ageValue length] < 1) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"&age=%@", [self URLEncodingFrom:ageValue]];
}

- (NSString *)genderParameter {
    ANGender genderValue = [self.adFetcherDelegate gender];
    if (genderValue == MALE) {
        return @"&gender=m";
    } else if (genderValue == FEMALE) {
        return @"&gender=f";
    } else {
        return @"";
    }
}

- (NSString *)customKeywordsParameter {
    __block NSString *customKeywordsParameter = @"";
    NSMutableDictionary *customKeywords = [self.adFetcherDelegate customKeywords];
    
    if ([customKeywords count] < 1) {
        return @"";
    }

    [customKeywords enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if ([value length] > 0)
            value = [customKeywords valueForKey:key];
        if (value) {
            customKeywordsParameter = [customKeywordsParameter stringByAppendingString:
                                       [NSString stringWithFormat:@"&%@=%@",
                                        key,
                                        [self URLEncodingFrom:value]]];
        }
    }];
    
    return customKeywordsParameter;
}

- (NSString *)extraParameters {
    NSString *extraString = @"";
    if ([self.adFetcherDelegate respondsToSelector:@selector(extraParameters)]) {
        NSArray *extraParameters = [self.adFetcherDelegate extraParameters];
        
        for (NSString *param in extraParameters) {
            extraString = [extraString stringByAppendingString:param];
        }
    }
    
    return extraString;
}

- (NSString *)jsonFormatParameter {
    return @"&format=json";
}

- (NSString *)supplyTypeParameter {
    return @"&st=mobile_app";
}

- (NSString *)sdkVersionParameter {
    return [NSString stringWithFormat:@"&sdkver=%@", AN_SDK_VERSION];
}

@end
