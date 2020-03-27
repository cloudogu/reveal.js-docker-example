let RevealTwemoji = {
  init: () => new Promise((resolve, reject) => {
    Reveal.addEventListener('ready', function(event) {
      twemoji.parse(document.body, {
        folder: 'svg',
        ext: '.svg'
      })
    })
    resolve()
  }),

}
Reveal.registerPlugin('revealTwemoji', RevealTwemoji)
