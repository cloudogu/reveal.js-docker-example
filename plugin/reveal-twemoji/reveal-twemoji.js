let RevealTwemoji = {
  init: () => new Promise((resolve, reject) => {
    Reveal.addEventListener('ready', function(event) {
      twemoji.parse(document.body, {
        folder: 'svg',
        ext: '.svg',
      // Fix because maxcdn has stopped supporting twemoji
      // See https://github.com/twitter/twemoji/issues/580
        base: 'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/'
      })
    })
    resolve()
  }),

}
Reveal.registerPlugin('revealTwemoji', RevealTwemoji)
