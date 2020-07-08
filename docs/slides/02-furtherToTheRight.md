## Separate files are placed to the right

Don't forget to add the markdown to `index.html`!

### Images

<!-- .slide: data-background-image="dist/theme/images/logo.png" data-background-size="50%" -->
<!-- .slide: style="text-align: left;" -->
 
Image via Markdown
![image](dist/theme/images/logo1.png)

<img src="dist/theme/images/logo1.png" class="floatLeft" width=20% />
<img src="dist/theme/images/logo1.png" class="floatRight" width=20% />
The images are floating right and left of this text via css
The image bellow is loaded lazily
<br/>
<img data-src="dist/theme/images/logo3.png" width=20% />



### Font
<!-- .slide: id="font" -->

* Normal
* <font color="red">red</font>  
  Line Break after two empty blanks
* <font size="1">Smaller text</font>



### Ordered List

1. Ordered
1. List


Link to [previous slide](#font) (by id)

### Video


<iframe width="560" height="315" src="https://www.youtube.com/embed/4ht22ReBjno" allow="encrypted-media" allowfullscreen></iframe>



### Different css on `document` of the slide

<!-- .slide: data-state="black-gradient" -->
Nice gradient! 



<!-- .slide: data-auto-animate  -->
<h1 style="margin-top: 100px;">Auto</h1>
<h1 style="opacity: 0;">Animate</h1>
<p style="opacity: 0;"></p>



<!-- .slide: data-auto-animate  -->
<h1>Auto</h1>
<h1>Animate</h1>
<p> you can transition things like position, font-size, line-height, color, background-color, padding and margin.<br/>
See <a href="https://revealjs.com/auto-animate/">docs</a>.</p>