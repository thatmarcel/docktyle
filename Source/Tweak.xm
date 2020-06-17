#import <Cephei/HBPreferences.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "Headers.h"
#import "DCKGradientView.h"

DCKGradientView *gradientView;

HBPreferences *preferences;
%ctor {
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.thatmarcel.tweaks.docktyle.hbprefs"];
    [preferences registerDefaults:@{
        @"style": @1,
        @"iosblurenabled": @true,
        @"enabled": @true,
        @"styletype": @0,
        @"alpha": @1.0,
        @"hidepagedots": @false
    }];
}

// Hide page dots
%hook SBIconListPageControl

- (void) setHidden:(BOOL)hidden {
    %orig([preferences boolForKey:@"hidepagedots"] ? true : hidden);
}

%end

%hook MTMaterialView

- (void) setAlpha:(double)arg1 {
    if ([self.superview isKindOfClass:%c(SBDockView)] || [self.superview isKindOfClass:%c(SBFloatingDockView)]) {
        %orig([preferences doubleForKey:@"alpha"]);
    } else {
        %orig(arg1);
    }
}

- (void) setHidden:(BOOL)hidden {
    if (![self.superview isKindOfClass:%c(SBDockView)] && ![self.superview isKindOfClass:%c(SBFloatingDockView)]) {
        return;
    }
    %orig([preferences integerForKey:@"styletype"] != 0 ? true : hidden);
}

%end

%hook SBDockView

- (void) setBackgroundView:(MTMaterialView *)backgroundView {
    if (self.backgroundView != nil) {
        %orig;
        return;
    }

    %orig;

    if (backgroundView.materialLayer == nil || [preferences boolForKey:@"enabled"] == false) {
        return;
    }

    // iOS style
    if ([preferences integerForKey:@"styletype"] == 0) {
        if ([backgroundView respondsToSelector:@selector(setRecipe:)] == false ||
            backgroundView.materialLayer == nil) {
            return;
        }

        [backgroundView setRecipe:[preferences integerForKey:@"style"]];

        [backgroundView.materialLayer setBlurEnabled:[preferences boolForKey:@"iosblurenabled"]];
        [backgroundView setAlpha:[preferences doubleForKey:@"alpha"]];

        return;
    }

    // Dock hidden
    if ([preferences integerForKey:@"styletype"] == 3) {
        backgroundView.hidden = true;
        return;
    }

    // Gradient or solid color

    gradientView = [[DCKGradientView alloc] initWithFrame: backgroundView.frame];
    gradientView.translatesAutoresizingMaskIntoConstraints = false;

    [gradientView loadWithPrefs: preferences];

    // Add corner radius on iPhone X+
    gradientView.layer.masksToBounds = true;

    NSArray *notchModels = @[
        @"iPhone10,3", @"iPhone10,6",                // iPhone X
        @"iPhone11,2", @"iPhone11,4", @"iPhone11,6", // iPhone XS (Max)
        @"iPhone11,8",                               // iPhone XR
        @"iPhone12,1", @"iPhone12,3", @"iPhone12,5", // iPhone 11 (Pro (Max))
    ];

    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    BOOL shouldRoundDock = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ||
                           [notchModels containsObject: deviceModel] ||
                           [[NSFileManager defaultManager] fileExistsAtPath: @"/var/lib/dpkg/info/com.noisyflake.moderndock.list"];

    gradientView.layer.cornerRadius = shouldRoundDock ? 30.0 : 0.0;

    [self insertSubview: gradientView atIndex: 0];

    [gradientView.topAnchor    constraintEqualToAnchor: backgroundView.topAnchor    ].active = true;
    [gradientView.bottomAnchor constraintEqualToAnchor: backgroundView.bottomAnchor ].active = true;
    [gradientView.leftAnchor   constraintEqualToAnchor: backgroundView.leftAnchor   ].active = true;
    [gradientView.rightAnchor  constraintEqualToAnchor: backgroundView.rightAnchor  ].active = true;

    [self layoutIfNeeded];
    [gradientView layoutIfNeeded];

    self.backgroundView.hidden = true;

    return;
}

%end

%hook SBFloatingDockView

- (void) setBackgroundView:(MTMaterialView *)backgroundView {
    if (self.backgroundView != nil) {
        %orig;
        return;
    }

    %orig;

    if (backgroundView.materialLayer == nil || [preferences boolForKey:@"enabled"] == false) {
        return;
    }

    // iOS style
    if ([preferences integerForKey:@"styletype"] == 0) {
        if ([backgroundView respondsToSelector:@selector(setRecipe:)] == false ||
            backgroundView.materialLayer == nil) {
            return;
        }

        [backgroundView setRecipe:[preferences integerForKey:@"style"]];

        [backgroundView.materialLayer setBlurEnabled:[preferences boolForKey:@"iosblurenabled"]];
        [backgroundView setAlpha:[preferences doubleForKey:@"alpha"]];

        return;
    }

    // Dock hidden
    if ([preferences integerForKey:@"styletype"] == 3) {
        backgroundView.hidden = true;
        return;
    }

    // Gradient or solid color

    gradientView = [[DCKGradientView alloc] initWithFrame: backgroundView.frame];
    gradientView.translatesAutoresizingMaskIntoConstraints = false;

    [gradientView loadWithPrefs: preferences];

    // Add corner radius
    gradientView.layer.masksToBounds = true;

    gradientView.layer.cornerRadius = 30.0;

    [self insertSubview: gradientView atIndex: 0];

    [gradientView.topAnchor    constraintEqualToAnchor: backgroundView.topAnchor    ].active = true;
    [gradientView.bottomAnchor constraintEqualToAnchor: backgroundView.bottomAnchor ].active = true;
    [gradientView.leftAnchor   constraintEqualToAnchor: backgroundView.leftAnchor   ].active = true;
    [gradientView.rightAnchor  constraintEqualToAnchor: backgroundView.rightAnchor  ].active = true;

    [self layoutIfNeeded];
    [gradientView layoutIfNeeded];

    self.backgroundView.hidden = true;

    return;
}

%end
