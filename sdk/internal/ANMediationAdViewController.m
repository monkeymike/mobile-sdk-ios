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

#import "ANMediationAdViewController.h"

#import "ANBannerAdView.h"
#import "ANGlobal.h"
#import "ANInterstitialAd.h"
#import "ANLogging.h"

@interface ANMediationAdViewController () <ANCustomAdapterBannerDelegate, ANCustomAdapterInterstitialDelegate>

@property (nonatomic, readwrite, strong) id<ANCustomAdapter> currentAdapter;
@property (nonatomic, readwrite, assign) BOOL hasSucceeded;
@property (nonatomic, readwrite, assign) BOOL hasFailed;
@property (nonatomic, readwrite, assign) BOOL timeoutCanceled;
@property (nonatomic, readwrite, strong) ANAdFetcher *fetcher;
@property (nonatomic, readwrite, strong) id<ANAdViewDelegate> adViewDelegate;
@property (nonatomic, readwrite, strong) NSString *resultCBString;
@end

@implementation ANMediationAdViewController

+ (ANMediationAdViewController *)initWithFetcher:fetcher adViewDelegate:(id<ANAdViewDelegate>)adViewDelegate {
    ANMediationAdViewController *controller = [[ANMediationAdViewController alloc] init];
    controller.fetcher = fetcher;
    controller.adViewDelegate = adViewDelegate;
    return controller;
}

- (void)setAdapter:adapter {
    self.currentAdapter = adapter;
}

- (void)clearAdapter {
    if (self.currentAdapter)
        self.currentAdapter.delegate = nil;
    self.currentAdapter = nil;
    self.hasSucceeded = NO;
    self.hasFailed = YES;
    self.fetcher = nil;
    self.adViewDelegate = nil;
    ANLogInfo(ANErrorString(@"mediation_finish"));
}

- (void)setResultCBString:(NSString *)resultCBString {
    _resultCBString = resultCBString;
}

- (BOOL)requestAd:(CGSize)size
  serverParameter:(NSString *)parameterString
         adUnitId:(NSString *)idString
           adView:(id<ANAdFetcherDelegate>)adView {
    // create targeting parameters object from adView properties
    ANTargetingParameters *targetingParameters = [ANTargetingParameters new];
    targetingParameters.customKeywords = adView.customKeywords;
    targetingParameters.age = adView.age;
    targetingParameters.gender = adView.gender;
    targetingParameters.location = adView.location;
    targetingParameters.idforadvertising = ANUdidParameter();

    // if the class implements both banner and interstitial protocols, default to banner first
    if ([[self.currentAdapter class] conformsToProtocol:@protocol(ANCustomAdapterBanner)]) {
        // make sure the container is a banner view
        if ([adView isKindOfClass:[ANBannerAdView class]]) {
            ANBannerAdView *banner = (ANBannerAdView *)adView;

            id<ANCustomAdapterBanner> bannerAdapter = (id<ANCustomAdapterBanner>) self.currentAdapter;
            [bannerAdapter requestBannerAdWithSize:size
                                rootViewController:banner.rootViewController
                                   serverParameter:parameterString
                                          adUnitId:idString
                               targetingParameters:targetingParameters];
            return YES;
        }
    } else if ([[self.currentAdapter class] conformsToProtocol:@protocol(ANCustomAdapterInterstitial)]) {
        // make sure the container is an interstitial view
        if ([adView isKindOfClass:[ANInterstitialAd class]]) {
            id<ANCustomAdapterInterstitial> interstitialAdapter = (id<ANCustomAdapterInterstitial>) self.currentAdapter;
            [interstitialAdapter requestInterstitialAdWithParameter:parameterString
                                                           adUnitId:idString
                                                           targetingParameters:targetingParameters];
            return YES;
        }
    }
    
    ANLogError([NSString stringWithFormat:ANErrorString(@"instance_exception"), @"ANCustomAdapterBanner or ANCustomAdapterInterstitial"]);
    self.hasFailed = YES;
    return NO;
}

#pragma mark ANCustomAdapterBannerDelegate

- (void)didLoadBannerAd:(UIView *)view {
	[self didReceiveAd:view];
}

#pragma mark ANCustomAdapterInterstitialDelegate

- (void)didLoadInterstitialAd:(id<ANCustomAdapterInterstitial>)adapter {
	[self didReceiveAd:adapter];
}

#pragma mark ANCustomAdapterDelegate

- (void)didFailToLoadAd:(ANAdResponseCode)errorCode {
    [self didFailToReceiveAd:errorCode];
}

- (void)adWasClicked {
    if (self.hasFailed) return;
    [self.adViewDelegate adWasClicked];
}

- (void)willPresentAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillPresent];
}

- (void)didPresentAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adDidPresent];
}

- (void)willCloseAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillClose];
}

- (void)didCloseAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adDidClose];
}

- (void)willLeaveApplication {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillLeaveApplication];
}

- (void)failedToDisplayAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adFailedToDisplay];
}

#pragma mark helper methods

- (BOOL)checkIfHasResponded {
    // don't succeed or fail more than once per mediated ad
    if (self.hasSucceeded || self.hasFailed) {
        return YES;
    }
    [self cancelTimeout];
    return NO;
}

- (void)didReceiveAd:(id)adObject {
    if ([self checkIfHasResponded]) return;
    self.hasSucceeded = YES;
    
    ANLogDebug(@"received an ad from the adapter");
    
    [self.fetcher fireResultCB:self.resultCBString reason:ANAdResponseSuccessful adObject:adObject];
}

- (void)didFailToReceiveAd:(ANAdResponseCode)errorCode {
    if ([self checkIfHasResponded]) return;
    [self.fetcher fireResultCB:self.resultCBString reason:errorCode adObject:nil];
    [self clearAdapter];
}

#pragma mark Timeout handler

- (void)startTimeout {
    if ([self checkIfHasResponded]) return;
    self.timeoutCanceled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 kAppNexusMediationNetworkTimeoutInterval
                                 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       if (self.timeoutCanceled) return;
                       ANLogWarn(ANErrorString(@"mediation_timeout"));
                       [self didFailToReceiveAd:ANAdResponseInternalError];
                   });
    
}

- (void)cancelTimeout {
    self.timeoutCanceled = YES;
}

@end