library video_player_oneplusdream;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../video_player_oneplusdream_platform_interface.dart';

export 'src/controller.dart'
    if (dart.library.io) 'src/controller.mobile.dart'
    if (dart.library.html) 'src/controller.web.dart';

part 'src/video_player_global.dart';
part 'src/video_player.widget.dart';
part 'src/video_player_setting.model.dart';
part 'src/video_player_event.model.dart';
part 'src/controller.stub.dart';
