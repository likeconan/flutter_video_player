function oneplusdreamInitialPlayer(player, params, videoId) {
  player.playlist(params.playingItems.map(function (item) {
    return {
      sources: [{
        src: item.url
      }],
    }
  }))
  player.playlist.autoadvance(params.initialPlayIndex || 0);
  const TitleBar = videojs.getComponent('TitleBar');
  const titleBar = new TitleBar(player)
  player.addChild(titleBar);
  player.on('play', function () {
    onPlayingEvent('play')
  })
  player.on('pause', function () {
    onPlayingEvent('pause')
  })
  player.on('error', function () {
    onPlayingEvent('error')
  })
  player.on('loadstart', function () {
    var item = params.playingItems.find(function (p) {
      return p.url === player.currentSrc();
    });
    titleBar.update({ title: (item || {}).title })
    if (item && item.position) {
      player.currentTime(item.position)
    }
    onPlayingEvent('start')
  });
  player.updateTitleFunc = function (title) {
    titleBar.update({ title: title })
  }
  player.on('ended', function () {
    onPlayingEvent('end')
  })
  player.on('abort', function () {
    onPlayingEvent('release')
  })
  const PLAYING_STATUS = { 'start': 0, 'pause': 1, 'play': 2, 'end': 3, 'error': 4, 'release': 5 };

  function onPlayingEvent(status) {
    var item = params.playingItems.find(function (p) {
      return p.url === player.currentSrc();
    }) || { id: player.currentSrc(), url: player.currentSrc() };
    window['oneplusdreamOnPlayerListen_' + videoId]('onPlaying', {
      item: item,
      status: PLAYING_STATUS[status],
      currentPosition: player.currentTime()
    })
  }
}