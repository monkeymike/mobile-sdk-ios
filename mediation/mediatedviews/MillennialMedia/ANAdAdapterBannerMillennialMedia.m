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


#import "ANAdAdapterBannerMillennialMedia.h"

#import "MMAdView.h"

@interface ANAdAdapterBannerMillennialMedia ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, readwrite, strong) MMAdView *mmAdView;
@end

@implementation ANAdAdapterBannerMillennialMedia
@synthesize delegate;

#pragma mark ANCustomAdapterBanner

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters
{
    NSLog(@"Requesting MillennialMedia banner with size %fx%f", size.width, size.height);
    [MMSDK initialize];
    [self addMMNotificationObservers];
    
    //MMRequest object
    MMRequest *request = [self createRequestFromTargetingParameters:targetingParameters];
    
    self.mmAdView = [[MMAdView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) apid:idString
                                 rootViewController:rootViewController];
    
    [self.mmAdView getAdWithRequest:request onCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"MillennialMedia banner did load");
            [self.delegate didLoadBannerAd:self.mmAdView];
        } else {
            NSLog(@"MillennialMedia banner failed to load with error: %@", error);
            ANAdResponseCode code = ANAdResponseInternalError;
            
            switch (error.code) {
                case MMAdUnknownError:
                    code = ANAdResponseInternalError;
                    break;
                case MMAdServerError:
                    code = ANAdResponseNetworkError;
                    break;
                case MMAdUnavailable:
                    code = ANAdResponseUnableToFill;
                    break;
                case MMAdDisabled:
                    code = ANAdResponseInvalidRequest;
                    break;
                default:
                    code = ANAdResponseInternalError;
                    break;
            }
            
            [self.delegate didFailToLoadAd:code];
        }
    }];
}

@end
