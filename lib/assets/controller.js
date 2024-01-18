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

  if (!params.hideBackButton) {
    const titleEle = titleBar.el();
    titleEle.setAttribute('style', 'display:flex; align-items:center;pointer-events: auto')
    const i = renderArrowBackIcon();
    titleEle.prepend(i);

    i.addEventListener('click', function () {
      window['oneplusdreamOnPlayerListen_' + videoId]('onBack')
    })
  }


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
    if (window['oneplusdreamOnPlayerListen_' + videoId]) {
      window['oneplusdreamOnPlayerListen_' + videoId]('onPlaying', {
        item: item,
        status: PLAYING_STATUS[status],
        currentPosition: player.currentTime(),
        duration: player.duration()
      })
    } else {
      console.error('no event listener for ' + videoId);
    }

  }
}

function renderArrowBackIcon() {
  const div = document.createElement('div');
  div.setAttribute('style', 'padding: 6px 12px;')
  const i = document.createElement('i');
  i.setAttribute('style', 'border: solid white;border-width: 0 3px 3px 0;display: inline-block; padding: 6px;transform: rotate(135deg);-webkit-transform: rotate(135deg);')
  div.appendChild(i)
  return div;
}
