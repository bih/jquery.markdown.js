// jquery.markdown.js
// This jQuery plugin provides a built-in WYSIWYG Markdown editor that's simple, fast, and powerful.
// 
// Released under the MIT License
// Author website: http://bilaw.al/
// Blog post: http://bilaw.al/jquery-markdown-js/
// Git Repository: http://github.com/bih/jquery.markdown.js

(function() {

  if (typeof jQuery === 'undefined') {
    alert('jquery.markdown.js >> jquery is required to run this.');
  }

  $.fn.markdown = function(params) {
    var clean_nested_divs, count_text, encode_text, markdown_cache, parse, repeat_text, sanitize_blockquotes, selector, set_development, set_editable, set_focus, set_spellcheck, set_text, textarea, unbind;
    if (typeof $(this) === 'undefined') {
      return console.error('jquery.markdown.js >> selector "' + $(this).selector + '" does not exist');
    }
    selector = $(this);
    markdown_cache = [];
    params = $.extend({
      class_name: "jquery-markdown-editor",
      textarea_name: "jquery-markdown-text",
      text: "",
      focus: false,
      onload: false,
      onchange: false,
      editable: true,
      spellcheck: false,
      development: false
    }, params);
    selector.addClass(params.class_name).after("<textarea name='" + params.textarea_name + "' id='" + params.textarea_name + "' class='jquery-markdown-text'></textarea>").attr({
      'contentEditable': params.editable,
      'spellCheck': params.spellcheck,
      'isjQueryMDObject': true
    });
    textarea = $("textarea#" + params.textarea_name);
    unbind = function() {
      selector.unbind().removeAttr().removeClass();
      selector.find('div, span').removeAttr().removeClass();
      textarea = null;
      selector = null;
      return true;
    };
    set_editable = function(option) {
      if (typeof option === 'undefined') {
        return params.editable;
      }
      params.editable = option;
      selector.attr({
        contentEditable: option
      });
      parse();
      return this;
    };
    set_spellcheck = function(option) {
      if (typeof option === 'undefined') {
        return params.spellcheck;
      }
      params.spellcheck = option;
      selector.attr({
        spellcheck: option
      });
      parse();
      return this;
    };
    set_development = function(option) {
      if (typeof option === 'undefined') {
        return params.development;
      }
      params.development = option;
      parse();
      return this;
    };
    set_focus = function() {
      if (params.editable === false) {
        return console.error("jquery.markdown.js >> Object editable is false. Please enable for focus to work.");
      }
      params.focus = true;
      selector.focus();
      return this;
    };
    set_text = function(text) {
      selector.html(encode_text(text));
      parse();
      return this;
    };
    encode_text = function(text) {
      var input, input_tmp;
      if (text === '<br>') {
        return text;
      }
      input = $('<div/>').text(text).html();
      while (true) {
        input_tmp = input.replace('  ', '&nbsp; ');
        if (input_tmp === input) {
          break;
        }
        input = input_tmp;
      }
      return input;
    };
    repeat_text = function(text, times) {
      var output;
      output = [];
      while (output.length < times) {
        output.push(text);
      }
      return output.join('');
    };
    count_text = function(text, find) {
      var count, start;
      count = 0;
      start = 0;
      while (true) {
        if (text.substr(start, find.length) === find) {
          start += 2;
          count++;
        } else {
          break;
        }
      }
      return count;
    };
    sanitize_blockquotes = function(text) {
      var get_blockquotes;
      get_blockquotes = count_text(text, "> ");
      text = text.replace(repeat_text("> ", get_blockquotes), '');
      return text;
    };
    clean_nested_divs = function(obj) {
      var compiled_res;
      compiled_res = '';
      obj.find('div').each(function() {
        if ($(this).find('div').length === 0) {
          return compiled_res += $(this).text() + '\n';
        }
      });
      return compiled_res;
    };
    parse = function(event) {
      var i, is_change, line, line_editing, linenum, output, text_parsed, text_unparsed, text_unparsed_length, _i, _ref;
      if (selector.find('div div').length > 0) {
        selector.text(clean_nested_divs(selector));
        parse();
        return false;
      }
      textarea.empty();
      if (typeof event !== 'undefined' && event.which === 9) {
        event.preventDefault();
      }
      line = [];
      linenum = 0;
      is_change = false;
      if (selector.find("pre, span[style]").length > 0) {
        selector.find("pre, span[style]").each(function() {
          var div_new_html, div_outer_html;
          div_new_html = $(this).parent('div').html();
          div_outer_html = $(this).clone().wrap('<div></div>').parent().html();
          if (typeof div_new_html !== 'undefined') {
            div_new_html = div_new_html.replace(div_outer_html, $(this).text());
          }
          return $(this).parent('div').html(div_new_html);
        });
      }
      if (selector.find("div").length === 0) {
        text_parsed = '';
        text_unparsed = selector.text().split('\n');
        text_unparsed_length = text_unparsed.length;
        for (i = _i = 0, _ref = text_unparsed_length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (text_unparsed[i] === '') {
            text_unparsed[i] = '<br>';
          }
          text_parsed += "<div>" + encode_text(text_unparsed[i]) + "</div>\n";
          is_change = true;
        }
        selector.html(text_parsed);
      }
      if (params.development === true) {
        line_editing = -1;
      }
      if (typeof event !== 'undefined') {
        selector.find("div").each(function() {
          if ($(this).text() !== markdown_cache[linenum]) {
            line_editing = linenum;
          }
          markdown_cache[linenum] = $(this).text();
          return linenum++;
        });
      }
      linenum = 0;
      selector.find("div").each(function() {
        var explode_by_spaces, i, implode_by_spaces, is_code_block, linetext, search_for, _j, _k, _l, _m, _ref1, _ref2, _ref3, _ref4;
        line = $(this);
        linetext = encode_text(line.text());
        textarea.append(linetext + '\n');
        if (line_editing > -1 && linenum !== line_editing && params.development === true) {
          implode_by_spaces = [];
          explode_by_spaces = linetext.split(/\s+/);
          for (i = _j = 0, _ref1 = explode_by_spaces.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
            implode_by_spaces.push("<span>" + explode_by_spaces[i] + "</span>");
          }
          if (implode_by_spaces.length > 0 && implode_by_spaces.join(' ') !== '<span></span>') {
            line.html(implode_by_spaces.join(' '));
          }
          if (line.find('span').length > 0) {
            line.find('span').each(function() {
              var word, _ref2, _ref3, _ref4, _ref5;
              word = $(this);
              if (((_ref2 = word.text().substr(0, 2)) === "**" || _ref2 === "__") && ((_ref3 = word.text().substr(word.text().length - 2, 2)) === "**" || _ref3 === "__")) {
                return word.addClass('markdown-bold');
              } else if (((_ref4 = word.text().substr(0, 1)) === "*" || _ref4 === "_") && ((_ref5 = word.text().substr(word.text().length - 1, 1)) === "*" || _ref5 === "_")) {
                return word.addClass('markdown-italic');
              }
            });
          }
          linenum++;
          return;
        }
        if (line_editing > -1 && linenum !== line_editing && params.development === false) {
          linenum++;
          return;
        }
        line.removeClass().removeAttr();
        for (i = _k = 7; _k >= 1; i = --_k) {
          if (sanitize_blockquotes(linetext).substr(0, i + 1) === repeat_text("#", i) + " ") {
            line.addClass("markdown-h" + i);
            break;
          }
        }
        if (linetext === repeat_text("=", 13)) {
          line.addClass("markdown-h1 markdown-nocache").prev().addClass("markdown-h1 markdown-nocache");
        }
        if (linetext === repeat_text("-", 13)) {
          line.addClass("markdown-h2 markdown-nocache").prev().addClass("markdown-h2 markdown-nocache");
        }
        if (line.text().substr(0, 2) === "> ") {
          line.addClass('markdown-bquote markdown-bquote-level' + count_text(line.text(), "> "));
        }
        for (i = _l = 1; _l <= 20; i = ++_l) {
          search_for = i + ". ";
          if (sanitize_blockquotes(linetext).substr(0, search_for.length) === search_for) {
            line.addClass('markdown-ordlist markdown-ordlist-num' + i);
          }
        }
        if ((_ref2 = sanitize_blockquotes(linetext).substr(0, 2)) === "* " || _ref2 === "- ") {
          line.addClass('markdown-unordlist');
        }
        if ((_ref3 = sanitize_blockquotes(linetext)) === '* * *' || _ref3 === '***' || _ref3 === '*****' || _ref3 === '- - -' || _ref3 === '---------------------------------------') {
          line.addClass('markdown-hr');
        }
        if (line.text().length > 3) {
          is_code_block = 0;
        }
        if (linetext.length > 3) {
          for (i = _m = 0; _m <= 3; i = ++_m) {
            if ((_ref4 = line.text().substr(i, 1).charCodeAt()) === 32 || _ref4 === 160) {
              is_code_block++;
            }
          }
          if (is_code_block === 4) {
            line.addClass('markdown-code');
          }
        }
        if (typeof line.attr('class') === 'undefined') {
          line.addClass('markdown-none');
        }
        return linenum++;
      });
      output = {
        raw: function() {
          return textarea.text();
        },
        line: function() {
          return line_editing;
        }
      };
      if (params.onchange !== false && typeof params.onchange === 'function' && line_editing > -1) {
        params.onchange(output);
      }
      return output;
    };
    if (params.text.length > 0) {
      set_text(params.text);
    }
    parse();
    selector.unbind().bind('keyup keydown keypress', parse);
    textarea.unbind().bind('keyup keydown keypress', function() {
      selector.text($(this).text());
      return parse();
    });
    if (params.focus === true) {
      selector.focus();
    }
    if (params.onload !== false && typeof params.onload === 'function') {
      params.onload(this);
    }
    return {
      version: function() {
        return '1.0.0';
      },
      parse: parse,
      unbind: unbind,
      text: set_text,
      editable: set_editable,
      spellcheck: set_spellcheck,
      development: set_development,
      focus: set_focus,
      internal: {
        repeat: repeat_text,
        sanitize_blockquotes: sanitize_blockquotes,
        count: count_text
      }
    };
  };

}).call(this);
