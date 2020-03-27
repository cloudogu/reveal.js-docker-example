## Separate files are placed to the right

Don't forget to add the markdown to `index.html`!

### Images

<!-- .slide: data-background-image="css/images/logo.png" data-background-size="50%" -->
<!-- .slide: style="text-align: left;" -->
 
Image via Markdown
![image](css/images/logo1.png)

<img src="css/images/logo1.png" class="floatLeft" width=20% />
<img src="css/images/logo1.png" class="floatRight" width=20% />
The images are floating right and left of this text via css
The image bellow is loaded lazily
<br/>
<img data-src="css/images/logo3.png" width=20% />



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