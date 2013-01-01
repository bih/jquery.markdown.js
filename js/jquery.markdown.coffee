# jquery.markdown.js
# This jQuery plugin provides a built-in WYSIWYG Markdown editor that's simple, fast, and powerful.
# 
# Released under the MIT License
# Author website: http://bilaw.al/
# Blog post: http://bilaw.al/jquery-markdown-js/
# Git Repository: http://github.com/bih/jquery.markdown.js

# We must have jQuery installed.
# Note: We haven't tested it pre 1.8.2 so no guarantees.
alert 'jquery.markdown.js >> jquery is required to run this.' if typeof jQuery is 'undefined'

$.fn.markdown = (params) ->
	# Check if the sector exists
	return console.error 'jquery.markdown.js >> selector "' + $(this).selector + '" does not exist' if typeof $(this) is 'undefined'

	# Assign selector to _s
	selector = $ this

	# Used for optimization
	markdown_cache = []

	# jQuery's native $.extend to merge input params and default params
	params = $.extend {
		class_name:     "jquery-markdown-editor",
		textarea_name:  "jquery-markdown-text",
		text:           "",
		focus:          false,
		onload:         false,
		onchange:       false,
		editable:       true,
		spellcheck:     false,
		development:    false # This is for features that are still buggy.
	}, params

	# Make the [selector] editable, add textarea for form compatibility and style it accordingly to jquery.markdown.sass
	selector.addClass(params.class_name)
			.after("<textarea name='" + params.textarea_name + "' id='" + params.textarea_name + "' class='jquery-markdown-text'></textarea>")
		    .attr {
		    	'contentEditable':  params.editable,
		    	'spellCheck':       params.spellcheck,
		    	'isjQueryMDObject': true
		    }

	textarea = $ "textarea#"+params.textarea_name

	# Unbind the Markdown object
	unbind = () ->
		# Reset DOM object
		# Note: This overrides any custom attributes or classes the HTML document may have added. It's a priority to-do.
		selector.unbind().removeAttr().removeClass()
		selector.find('div, span').removeAttr().removeClass()
		# Delete the variables
		textarea = null
		selector = null
		return true

	# Update the editable attribute
	set_editable = (option) ->
		return params.editable if typeof option is 'undefined'

		params.editable = option
		selector.attr { contentEditable: option }
		parse()
		this

	# Update the spellcheck attribute
	set_spellcheck = (option) ->
		return params.spellcheck if typeof option is 'undefined'

		params.spellcheck = option
		selector.attr { spellcheck: option }
		parse()
		this

	# Update the development mode
	set_development = (option) ->
		return params.development if typeof option is 'undefined'
		
		params.development = option
		parse()
		this

	# Focus on the object
	set_focus = () ->
		return console.error "jquery.markdown.js >> Object editable is false. Please enable for focus to work." if params.editable is false
		
		params.focus = true
		selector.focus()
		this

	# Set text
	set_text = (text) ->
		selector.html encode_text(text)
		parse()
		this

	# Encode text to support ASCII & HTML5 ASCII issues.
	encode_text = (text) ->
		return text if text is '<br>'
		input = $('<div/>').text(text).html()
		while(true)
			input_tmp = input.replace('  ', '&nbsp; ')
			break if input_tmp is input
			input = input_tmp
		input

	# Internal tool: Repeat text
	repeat_text = (text, times) ->
		output = []
		output.push text while output.length < times
		output.join ''

	# Internal tool: Get count of text
	count_text = (text, find) ->
		count = 0
		start = 0
		while true
			if text.substr(start, find.length) == find
				start += 2
				count++
			else
				break
		count

	# Internal tool: Sanitize blockquote strings to support nested titles, etc.
	sanitize_blockquotes = (text) ->
		get_blockquotes = count_text(text, "> ")
		
		# Get blockquotes
		text = text.replace(repeat_text("> ", get_blockquotes), '')

		text

	# Internal tools: Cleanse Markdown when nested fields appear.
	clean_nested_divs = (obj) ->
		compiled_res = '';

		obj.find('div').each ->
			if $(this).find('div').length is 0
				compiled_res += $(this).text() + '\n'
		compiled_res

	# This function ensures Markdown parsing can be real-time
	parse = (event) ->
		# Bug fix. Is there nested divs? If so, restructure the entire thing for compatibility reasons.
		if selector.find('div div').length > 0
			selector.text clean_nested_divs(selector)
			parse()
			return false

		# Reset the textarea.
		textarea.empty()

		# Forget what the browsers tell us.
		event.preventDefault() if typeof event isnt 'undefined' and event.which is 9

		# This makes the loop smarter.
		line = [] # The jQuery object of the line we're on
		linenum = 0 # In the loop, what line are we on?
		is_change = false # For the callback.

		# Prevents uglifying the contentEditable by copying & pasting.
		if selector.find("pre, span[style]").length > 0
			selector.find("pre, span[style]").each ->
				div_new_html = $(this).parent('div').html();
				div_outer_html = $(this).clone().wrap('<div></div>').parent().html()
				div_new_html = div_new_html.replace(div_outer_html, $(this).text()) if typeof div_new_html isnt 'undefined'

				$(this).parent('div').html(div_new_html)

		# We accept raw Markdown too. Not just our HTML. Lovely jubbly.
		if selector.find("div").length is 0
			text_parsed =          ''
			text_unparsed =        selector.text().split('\n')
			text_unparsed_length = text_unparsed.length

			# Loop through each bit of unparsed text.
			for i in [0..text_unparsed_length-1]
				text_unparsed[i] = '<br>' if text_unparsed[i] is ''
				text_parsed += "<div>" + encode_text(text_unparsed[i]) + "</div>\n"
				is_change = true

			# Get the parsed text in the markdown HTML element.
			selector.html text_parsed

		# Let's get what line we're trying to edit.
		line_editing = -1 if params.development is true
		#line_editing = 0 if params.development is true and typeof event is 'undefined'
		if typeof event isnt 'undefined'
			selector.find("div").each ->
				line_editing = linenum if $(this).text() isnt markdown_cache[linenum]
				markdown_cache[linenum] = $(this).text()
				linenum++

		# Reset the linenum counter
		linenum = 0

		# This presumes it's already parsed. Let's re-parse it.
		selector.find("div").each ->

			# Let's not mix up contexts. Put the DOM model of this line in the 'line' variable.
			line = $ this
			linetext = encode_text line.text()

			# Before anything, it must be sync'ed in the textarea.
			textarea.append linetext + '\n'

			#########################
			# START MARKDOWN PARSER #
			#########################

			# This spaces each word out by a <span> element to support embedded syntax support (i.e. Hello **world**)
			if line_editing > -1 and linenum isnt line_editing and params.development is true
				implode_by_spaces = []
				explode_by_spaces = linetext.split(/\s+/)

				for i in [0..explode_by_spaces.length-1]
					implode_by_spaces.push("<span>" + explode_by_spaces[i] + "</span>")

				line.html implode_by_spaces.join(' ') if implode_by_spaces.length > 0 and implode_by_spaces.join(' ') isnt '<span></span>'

				# Process the embedded Markdown syntax.
				# Note: Development only. It is still very much buggy.
				if line.find('span').length > 0

					# Loop through each span
					line.find('span').each ->
						# This element
						word = $ this

						# Processing the ** and emphasis.
						# Source: http://daringfireball.net/projects/markdown/syntax#em
						if word.text().substr(0, 2) in ["**", "__"] and word.text().substr(word.text().length-2, 2) in ["**", "__"]
							word.addClass('markdown-bold')
						else if word.text().substr(0, 1) in ["*", "_"] and word.text().substr(word.text().length-1, 1) in ["*", "_"]
							word.addClass('markdown-italic')

				linenum++ 
				return

			# Make sure it works for anyone who disables development mode.
			if line_editing > -1 and linenum isnt line_editing and params.development is false
				linenum++
				return

			# Change has been made. Parse this line again.
			line.removeClass().removeAttr()

			# To improve the UX, we automatically add classes on to new lines that users may have.
			# Disabled by default. Uncomment the lines below to enable it.
			#
			# if linetext.length is 0
			# 	# Remove classes with numbers. They're specific to their relative lines.
			# 	class_split = String(line.prev().attr('class')).split(/\s+/)
			# 	for i in [0..class_split.length-1]
			# 		line.addClass(class_split[i]) if class_split[i].match(/\d+/g) is null and class_split[i] isnt 'undefined'
				
			# 	# There is room for automated increments.
			# 	# i.e. if you had "3. Do the shopping", the next line would prepend with "4. "
			# 	# I'm still figuring that one out. Bear with me.
			# 	return

			# Processing the # headers.
			# Source: http://daringfireball.net/projects/markdown/syntax#header
			for i in [7..1]
				if sanitize_blockquotes(linetext).substr(0, i+1) == repeat_text("#", i) + " "
					line.addClass "markdown-h"+i 
					break

			# Processing the ------ and ====
			# Source: http://daringfireball.net/projects/markdown/syntax#header
			if linetext is repeat_text "=", 13
				line.addClass("markdown-h1 markdown-nocache").prev().addClass("markdown-h1 markdown-nocache")

			if linetext is repeat_text "-", 13
				line.addClass("markdown-h2 markdown-nocache").prev().addClass("markdown-h2 markdown-nocache")

			# Processing the > blockquotes
			# Source: http://daringfireball.net/projects/markdown/syntax#blockquote
			if line.text().substr(0, 2) is "> "
				line.addClass('markdown-bquote markdown-bquote-level' + count_text(line.text(), "> "));

			# Processing the ordered lists
			# Note: parsing only goes up to 20 right now. Should be more than enough.
			# Source: http://daringfireball.net/projects/markdown/syntax#blockquote
			for i in [1..20]
				search_for = i + ". "
				line.addClass('markdown-ordlist markdown-ordlist-num'+i) if sanitize_blockquotes(linetext).substr(0, search_for.length) == search_for

			# Processing the unordered lists
			# Source: http://daringfireball.net/projects/markdown/syntax#blockquote
			if sanitize_blockquotes(linetext).substr(0, 2) in ["* ", "- "]
				line.addClass('markdown-unordlist')

			# Processing the horizontal rules
			# Source: http://daringfireball.net/projects/markdown/syntax#hr
			if sanitize_blockquotes(linetext) in ['* * *', '***', '*****', '- - -', '---------------------------------------']
				line.addClass('markdown-hr')

			# Processing paragraphs used in both ordered and unordered lists
			# Source: http://daringfireball.net/projects/markdown/syntax#blockquote
			# if line.prev().hasClass('markdown-ordlist') or line.prev().hasClass('markdown-unordlist') or line.prev().hasClass('markdown-list-paragraph')
			#  	for i in [0..3]
			#  		is_list_paragraph++ if linetext.substr(i, 1).charCodeAt() in [32, 160]
			 	
			#  	# According to John Gruber's spec, it must be 4 spaces with charCode 160. I've added ASCII code 32 support too.
			#  	if is_list_paragraph is 4
			#  		is_list_paragraph = 0 
			#  		line.addClass('markdown-list-paragraph')

			# Processing code blocks
			# Source: http://daringfireball.net/projects/markdown/syntax#precode
			is_code_block = 0 if line.text().length > 3
			if linetext.length > 3
			 	for i in [0..3]
			 		is_code_block++ if line.text().substr(i, 1).charCodeAt() in [32, 160]
			 	
			 	# According to John Gruber's spec, it must be 4 spaces with charCode 160. I've added ASCII code 32 support too.
			 	if is_code_block is 4
			 		line.addClass('markdown-code')


			# If there's nothing left, it definitely deserves a .markdown-none
			if typeof line.attr('class') is 'undefined'
				line.addClass('markdown-none')

			########################
			# STOP MARKDOWN PARSER #
			########################

			# Increment dude.
			linenum++

		# This is what will be output. It's in a variable so we can pass it through the callback function too.
		output = {
			raw:  -> textarea.text(),
			line: -> line_editing
		}

		# Built-in onchange callback API.
		params.onchange(output) if params.onchange isnt false and typeof params.onchange is 'function' and line_editing > -1

		# Return the output variable
		output

	
	# If the text param has been set, deal with it.
	set_text params.text if params.text.length > 0

	# Go for the initial parse
	parse()

	# Real-time, bitch. See http://youtu.be/wSMR-VBN7NyM
	selector.unbind().bind 'keyup keydown keypress', parse
	textarea.unbind().bind(
		'keyup keydown keypress', 
		() ->
			selector.text $(this).text()
			parse()
	)

	# Focus if params.focus is true
	selector.focus() if params.focus is true

	# onload callback
	params.onload(this) if params.onload isnt false and typeof params.onload is 'function'

	# Return functions and version as an API for re-processing.
	{
		version: 	 -> '1.0.0',
		parse: 		 parse,
		unbind:      unbind,
		text:        set_text,
		editable:    set_editable,
		spellcheck:  set_spellcheck,
		development: set_development,
		focus:       set_focus,
		internal: {
			repeat: 				repeat_text,
			sanitize_blockquotes: 	sanitize_blockquotes,
			count: 					count_text
		}
	}