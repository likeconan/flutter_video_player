#import "VideoPlayerOneplusdreamPlugin.h"
#if __has_include(<video_player_oneplusdream/video_player_oneplusdream-Swift.h>)
#import <video_player_oneplusdream/video_player_oneplusdream-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "video_player_oneplusdream-Swift.h"
#endif

@implementation VideoPlayerOneplusdreamPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVideoPlayerOneplusdreamPlugin registerWithRegistrar:registrar];
}
@end
