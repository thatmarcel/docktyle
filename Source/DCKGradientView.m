#import <Cephei/HBPreferences.h>
#import "Headers.h"
#import "DCKGradientView.h"

@implementation DCKGradientView
    @synthesize gradientLayer;

    - (void) layoutSubviews {
        [super layoutSubviews];

        self.gradientLayer.frame = self.bounds;
    }

    - (void) loadWithPrefs:(HBPreferences*)preferences {
        [self loadGradientWithPrefs: preferences];
    }

    - (void) loadGradientWithPrefs:(HBPreferences*)preferences {
        NSDictionary* preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.thatmarcel.tweaks.docktyle.scprefs.plist"];

        if (!preferencesDictionary) {
            return;
        }

        UIColor *color1;
        UIColor *color2;

        if ([preferences integerForKey:@"styletype"] ==  2) {
            NSString* color1String = [preferencesDictionary objectForKey: @"gradientcolorone"];
            NSString* color2String = [preferencesDictionary objectForKey: @"gradientcolortwo"];

            color1 = [SparkColourPickerUtils colourWithString: color1String withFallback: @"#FF416C"];
            color2 = [SparkColourPickerUtils colourWithString: color2String withFallback: @"#FF4B2B"];
        } else {
            NSString *colorString = [preferencesDictionary objectForKey: @"solidcolor"];
            color1 = [SparkColourPickerUtils colourWithString: colorString withFallback: @"#f5bd07"];
            color2 = [color1 copy];
        }

        [self addGradientLayerWithColor1: color1 andColor2: color2 andOpacity: [preferences doubleForKey: @"alpha"]];
    }

    - (void) addGradientLayerWithColor1:(UIColor*)color1 andColor2:(UIColor*)color2 andOpacity:(double)opacity {
        self.gradientLayer = [CAGradientLayer layer];

        self.gradientLayer.frame = self.bounds;
        self.gradientLayer.masksToBounds = true;

        self.gradientLayer.startPoint = CGPointMake(0.0, 0.5);
        self.gradientLayer.endPoint = CGPointMake(1.0, 0.5);

        self.gradientLayer.colors = @[
            (id) color1.CGColor,
            (id) color2.CGColor
        ];

        self.gradientLayer.opacity = opacity;

        [self.layer insertSublayer: self.gradientLayer atIndex: 0];
    }

@end
