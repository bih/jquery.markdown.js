![jquery.markdown.js logo](http://i.imgur.com/K6IrS.png)

# jquery.markdown.js | wysiwyg markdown editor
Markdown is a jQuery plugin (written in CoffeeScript) released under the [MIT License](http://opensource.org/licenses/MIT) that brings a beautiful, lightweight and standards-compliant WYSIWYG editor to your website. I've written a blog post on the philosophy behind Markdown [on my blog](http://bilaw.al/jquery-markdown-js/).

You can find a demo by [clicking here](http://htmlpreview.github.com/?https://github.com/bih/jquery.markdown.js/blob/master/demo/index.html).

Some of the features it boasts:
* Incredibly fast (and small) -- altogether it's 8KB compressed.
* Incredibly smart -- it tracks changes on-the-fly + lots more.
* Easy to install -- the editor posts raw markdown. no backend code needed.
* Extensible API -- build anything on top of the plugin. utilize all of its internal tools.
* Totally customizable -- make it look as if you made it. it's beautifully simple to edit in css.
* Well documented -- hack it to do anything you want outside it's capability.
* Fully HTML5 + CSS3 + jQuery. No useless dependencies. Fallback support using ```<noscript>``` and ```<textarea>```.

## Installation
It's incredibly easy to install. If you're cool, you can skip the first step (seriously!).

1. Download jquery.markdown.js to desired local directory
```https://github.com/bih/jquery.markdown.js/archive/master.zip```

2. In your HTML document, include this in your header:
```<link rel="stylesheet" href="css/jquery.markdown.css" type="text/css" />```

3. Insert this to where you want the editor
```<div id="markdown-editor"></div>```

4. Then insert this in your footer.
```<script type="text/javascript" src="css/jquery.markdown.js"></script>
<script type="text/javascript">
  // The first parameter is the code below is the pre-instance API.
  var instance = $("#markdown-editor").markdown({
    editable: true
  });

  // instance is now the post-instance API.
</script>```

5. Your now successfully installed!

## Advanced
This plugin boasts a powerful, extensive API (in two forms: pre-and-post instance) for full control.

#### Pre-instance API
The settings you can load when initializing the .markdown() instance are:
* [class_name]           -- This allows you to customize the styling of each Markdown instance.
* [textarea_name]        -- This allows you to set the name of the textarea which posts raw Markdown.
* [focus]                -- Whether the editor should be in focus on loading.
* [spellcheck]           -- Whether you wish to enable HTML5's native spellcheck feature.
* [editable]             -- Should the editor be editable? This can be enabled at anytime using the post-instance API.
* [text]                 -- Any Markdown you wish to load? Highly recommended over others.
* [onload]               -- Run an anonymous or named function when instance is fully loaded.
* [onchange]             -- Run an anonymous or named function when text is changed.
* [development]          -- Active our unstable features? Only for those playing about with the code.

##### Post-instance API
The functions you can call under "instance" or whatever your variable is (i.e. "instance.development(true)") are:
* .development(true|false)     -- This enables/disables the unstable features.
* .editable(true|false)        -- This enables/disables whether you can edit on the editor.
* .focus()                     -- This places focus on the editor.
* .parse()                     -- Manually parse. If you changed the content via jQuery (and not the library), use this to parse.
* .spellcheck(true|false)      -- This enables/disables the native HTML5 spellcheck functionality.
* .text("# Hello...")          -- This changes the Markdown text in the editor (and re-parses). New line split by \n.
* .version()                   -- This shows the jquery.markdown version number of the instance.
* .unbind()                    -- This unbinds the jquery.markdown library to this object.


## About
This plugin was happily developed by Bilawal Hameed, a hacker and entrepreneur. I hated two editors for one piece of text, so I experimented with HTML5 to come up with this hack. Ideally, it should improve into one great piece of kit for websites who care about UI.

It's not ready for production yet. It doesn't support the full Markdown specification [full John Gruber Markdown specification](http://daringfireball.net/projects/markdown/syntax). It's a hack over a couple of hours, and I felt that it would improve faster by releasing it in the wild.

Tweet me at [@bilawalhameed](http://twitter.com/bilawalhameed) if you're stuck.