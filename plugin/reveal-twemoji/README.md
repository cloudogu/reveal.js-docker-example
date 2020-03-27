# twemoji-reveal

Replaces UTF-8 emoji in reveal.js presentations with corresponding images 
(based on [twemoji](https://github.com/twitter/twemoji))


## Installation

### Install twemoji
```sh
yarn add twemoji
```
### Use `grunt-contrib-copy` to copy twemoji to `lib` 
```sh
yarn add grunt-contrib-copy --dev
```
Copy assets in `gruntfile.js`:
```js
copy: {
  twemoji: {
    files: [
      {
        expand: true,
        cwd: 'node_modules/twemoji/dist',
        src: '**',
        dest: 'lib/'
      } 
    ]
  }
}
...
grunt.registerTask('twemoji-reveal', ['copy:twemoji'])
```
### Add task to package.json
```js
scripts: {
...
  "start": "grunt twemoji serve"
}
```
### Add script to `index.html`
```html
<script src="lib/dist/twemoji.min.js"
```
### Add plugin to `index.html`
```js
Reveal.initialize({
...
dependencies: [
  { src: 'plugin/reveal-twemoji/reveal-twemoji.js'}
]
})
```
### Add styles to your stylesheet
```css
.reveal section img.emoji {
   height: 1em;
   width: 1em;
   margin: 0 .05em 0 .1em;
   vertical-align: -0.1em;
}
```
