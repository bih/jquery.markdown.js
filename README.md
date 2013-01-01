![jquery.markdown.js logo](http://i.imgur.com/K6IrS.png)

# jquery.markdown.js | wysiwyg markdown editor
Markdown is a jQuery plugin (written in CoffeeScript) that brings a beautiful, lightweight and standards-compliant WYSIWYG editor to your website. I've written a blog post on the philosophy behind Markdown [on my blog](http://bilaw.al/jquery-markdown-js/).

Some of the features it boasts:
> Incredibly fast (and small) -- altogether it's 8KB compressed.
> Incredibly smart -- it tracks changes on-the-fly + lots more.
> Easy to install -- the editor posts raw markdown. no backend code needed.
> Extensible API -- build anything on top of the plugin. utilize all of its internal tools.
> Totally customizable -- make it look as if you made it. it's beautifully simple to edit in css.
> Well documented -- hack it to do anything you want outside it's capability.
> Fully HTML5 + CSS3 + jQuery. No useless dependencies. Fallback support using <noscript> and <textarea>.

## Installation
It's incredibly easy to install. If you're cool, you can skip the first step (seriously!).

1. Download jquery.markdown.js to desired local directory
    https://github.com/bih/jquery.markdown.js/archive/master.zip

2. In your HTML document, include this in your header:
    <link rel="stylesheet" href="css/jquery.markdown.css" type="text/css" />

3. Insert this to where you want the editor
    <div id="markdown-editor"></div>

4. Then insert this in your footer.
    <script type="text/javascript" src="css/jquery.markdown.js"></script>
    <script type="text/javascript">
      // The first parameter is the code below is the pre-instance API.
      var instance = $("#markdown-editor").markdown({
                       editable: true
                     });

      // instance is now the post-instance API.
    </script>

5. Your now successfully installed!

## Advanced
This plugin boasts a powerful, extensive API (in two forms: pre-and-post instance) for full control.

#### Pre-instance API
The settings you can load when initializing the .markdown() instance are:
> [class_name]           -- This allows you to customize the styling of each Markdown instance.
> [textarea_name]        -- This allows you to set the name of the textarea which posts raw Markdown.
> [focus]                -- Whether the editor should be in focus on loading.
> [spellcheck]           -- Whether you wish to enable HTML5's native spellcheck feature.
> [editable]             -- Should the editor be editable? This can be enabled at anytime using the in
> [text]                 -- Any Markdown you wish to load? This method is highly recommended over other forms to avoid browser rendering of tags.
> [onload]               -- Run an anonymous or named function when text is changed.
> [onchange]             -- Run an anonymous or named function when text is changed.
> [development]          -- Active our unstable features? Only for those playing about with the code.

##### Post-instance API
The functions you can call under "instance" or whatever your variable is (i.e. "instance.development(true)") are:
> .development(true|false)     -- This enables/disables the unstable features.
> .editable(true|false)        -- This enables/disables whether you can edit on the editor.
> .focus()                     -- This places focus on the editor.
> .parse()                     -- Manually parse. If you changed the content via jQuery (and not the library), use this to parse.
> .spellcheck(true|false)      -- This enables/disables the native HTML5 spellcheck functionality.
> .text("# Hello...")          -- This changes the Markdown text in the editor and re-parses automatically.
> .version()                   -- This shows the jquery.markdown version number of the instance.
> .unbind()                    -- This unbinds the jquery.markdown library to this object.


## About
This plugin was happily developed by Bilawal Hameed, a hacker and entrepreneur. I hacked HTML5 to discover this functionality, and quite frankly, I hated two editors for one piece of text. So, all grace, jquery.markdown should develop into a great piece of kit.

I won't say it's quite ready for production just yet. It doesn't support the (full John Gruber Markdown specification](http://daringfireball.net/projects/markdown/syntax) but it should very quickly. I merely hacked this together in a week, and I felt it would be great to open source for all these beautiful websites who deserve a half-decent Markdown experience.