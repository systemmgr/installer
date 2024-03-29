#!/usr/bin/env -S sed -Ef

### md-to-html: Sed script that converts Markdown to HTML code

s/\t/  /g
s/^ +$//

# HTML entities
s/(>=|=>)/\&ge\;/g
s/(<=|=<)/\&le\;/g
s/\&/\&amp\;/g
s/"/\&quot\;/g
s/'/\&apos\;/g
s/>/\&gt\;/g
s/</\&lt\;/g

s/([^\\]):[a-zA-Z0-9]+:/\1\&#x2B50\;/g

s/\\\&ge\;/=>/g
s/\\\&le\;/<=/g
s/\\\&amp\;/\&/g
s/\\\&quot\;/"/g
s/\\\&apos\;/'/g
s/\\\&gt\;/>/g
s/\\\&lt\;/</g

## Code snippets
/^ *```/{
    # Exchange hold and pattern spaces
    x
    # Hold space did not start with three backticks
    /^ *```/!{
        N
        s/.*\n/\n\\<pre\\>\\<code\\>/
        D
    }
    # Remove everything from hold space
    s/.*//
    x
    # This is where the code block ends
    s/.*/<\/code><\/pre>/
    b
}

x
# If a block of code is being processed, jump forward to next line
/^ *```/{
    x
    b
}
x

## Per-word formatting

# <text>
s/(^| )\&lt\; *([^ ]*[:\/][^ ]*) *\&gt\;( |$)/\1<a href="\2">\2<\/a>\3/g
s/(^| )\&lt\; *([^ ]*@[^ ]+) *\&gt\;( |$)/\1<a href="mailto:\2">\2<\/a>\3/g

# Currently using '[[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]+' in place of '.*'

# [![image](url)](url)
s/\[!\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]+) *\] *\( *([^ ]+) *\) *] *\( *([^ ]+) *\)/<a href="\3"><img src="\2" alt="\1"><\/a>/g

# ![image](url)
s/!\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]) *\] *\( *([^ ]+) *\)/<img src="\2" alt="\1">/g

# [Web site](url)
s/\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+-]) *\] *\( *([^ ]+) *"([^"]+)"\)/<a href="\2" title="\3">\1<\/a>/g
s/\[ *([[:alnum:] \&\;\?!,\)\+]*.{0,10}[[:alnum:] \&\;\?!,\)\+]+) *\] *\( *([^ ]+) *\)/<a href="\2">\1<\/a>/g

# ***text*** and ___text___
s/(^|[^\\\*])\*{3}([^\*]+)\*{3}([^\*]|$)/\1<strong><em>\2<\/em><\/strong>\3/g
s/(^|[^\\_])_{3}([^_]+)_{3}([^_]|$)/\1<strong><em>\2<\/em><\/strong>\3/g

# **text** and __text__
s/(^|[^\\\*])\*{2}([^\*]+)\*{2}([^\*]|$)/\1<strong>\2<\/strong>\3/g
s/(^|[^\\_])_{2}([^\_]+)_{2}([^_]|$)/\1<strong>\2<\/strong>\3/g

# *text* and _text_
s/(^|[^\\\*])\*([^\*]+)\*([^\*]|$)/\1<em>\2<\/em>\3/g
s/(^|[^\\_])_([^_]+)_([^_]|$)/\1<em>\2<\/em>\3/g

# ~~text~~
s/(^|[^\\~])~~([^~]+)~~([^~]|$)/\1<del>\2<\/del>\3/g
s/(^|[^\\~])~([^~]+)~([^~]|$)/\1<s>\2<\/s>\3/g

# `text`
s/(^|[^\\`])`([^`]+)`([^`]|$)/\1<code>\2<\/code>\3/g

## Numbered lists, bulleted lists, blockquotes

/^ *[0-9]+ *[\.-]|^ *[\*\+-] *[^\*\+-]|^ *\&gt\;/{
    H
    # Only when we are not at the last line, start a new cycle
    $!d
}

# Find out what's being held
x

/(^|\n) *[0-9]+ *[\.-]/{
    # Add "<oli>" and "</oli>" to all occurrences
    s/(^|\n)( *)[0-9]+ *[\.-] *([^\n]+)/\1\2<oli>\3<\/oli>/g
    # Add "<ol>" and "</ol>" tags, up to 3 levels are supported
    s/(^|\n)<oli>[^\n]+<\/oli>(\n *<oli>[^\n]+<\/oli>)*/\1<ol>&\n<\/ol>/g
    s/(^|\n)( )<oli>[^\n]+<\/oli>(\n\2 *<oli>[^\n]+<\/oli>)*/\1\2<ol>&\n\2<\/ol>/g
    s/(^|\n)( {2})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g
    s/(^|\n)( {3})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g
    s/(^|\n)( {4})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g
    s/(^|\n)( {5,})<oli>[^\n]+<\/oli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ol>&\n\2<\/ol>/g
}

# These are copied from the previous block
# except for the regular expressions and HTML tags
/(^|\n) *[\*\+-]/{
    s/(^|\n)( *)[\*\+-] *([^\n]+)/\1\2<uli>\3<\/uli>/g
    s/(^|\n)<uli>[^\n]+<\/uli>(\n *<uli>[^\n]+<\/uli>)*/\1<ul>&\n<\/ul>/g
    s/(^|\n)( )<uli>[^\n]+<\/uli>(\n\2 *<uli>[^\n]+<\/uli>)*/\1\2<ul>&\n\2<\/ul>/g
    s/(^|\n)( {2})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g
    s/(^|\n)( {3})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g
    s/(^|\n)( {4})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g
    s/(^|\n)( {5,})<uli>[^\n]+<\/uli>(\n\2 *<[ou]li>[^\n]+<\/[ou]li>)*/\1\2<ul>&\n\2<\/ul>/g
}

/(^|\n) *\&gt\;/{
    # Loop until all the leading ">" signs become spaces
    :b
    /(^|\n) *\&gt\; */{
        s/(^|\n)( *)\&gt\;/\1 /g
        tb
    }
    s/(^|\n)( *)\&gt\; *([^\n]+)/\1\2<p>\3<\/p>/g
    s/(^|\n)<p>[^\n]+<\/p>(\n *<p>[^\n]+<\/p>)*/\1<blockquote>&\n<\/blockquote>/g
    s/(^|\n)( )<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g
    s/(^|\n)( {2})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g
    s/(^|\n)( {3})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g
    s/(^|\n)( {4})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g
    s/(^|\n)( {5,})<p>[^\n]+<\/p>(\n\2 *<p>[^\n]+<\/p>)*/\1\2<blockquote>&\n\2<\/blockquote>/g
}

# If any of the previous matches were successful
/\n *<[ou]li>|\n *<p>/{
    s/<(\/?)[ou]li>/<\1li>/g
    # Remove escape characters
    s/([^\\])\\(.)/\1\2/g
    s/^\n+//
    p
    s/.*//
}

x

# Remove escape characters again (exact copy of the former)
s/([^\\])\\(.)/\1\2/g

## Headers and paragraphs

/^ *[^#]/{
    ${
        # If we came here from above, don't print the same line twice
        /^ *[0-9]+ *[\.-]|^ *[\*\+-] *[^\*\+-]|^ *\&gt\;/d
        # Otherwise, if a multi-line paragraph was being processed
        /<\/pp>$/{
            s/<\/pp>$/<\/p>/
            b
        }
        # If we got here, the last line is a paragraph on its own
        s/.*/<p>&<\/p>/
        # We can't append the next line because there are no more left
        b
    }
    N
    # We've attached the next line to the current pattern space
    # Find out whether first line was a header
    /\n *[=-]+ *$/{
        s/^ *(.*)\n *=+ */# \1/
        s/^ *(.*)\n *-+ */## \1/
    }
    /^ *#/!{
        # First line is within a paragraph, look at the second one
        /\n *[0-9]+ *[\.-]|\n *[\*\+-]|\n *>|\n *#|\n *$/{
            # Second line is either a list or a header, or it's blank
            # Polish the first line
            /<\/pp>\n/{
                s/ *<\/pp>\n/<\/p>\n/
                # Continue on next line
                P
                D
            }
            # Make the first line a paragraph on its own
            s/^ *([^\n]+)/<p>\1<\/p>/
            P
            D
        }
        # Second line belongs to a paragraph
        # Find out if a multi-line paragraph was just being processed
        /<\/pp>\n/{
            s/ *<\/pp>\n/\n/
            s/$/\\<\/pp\\>/
            # Continue on next line
            P
            D
        }
        # If that wasn't the case, make this a multi-line paragraph
        s/.*/<p>&\\<\/pp\\>/
        P
        D
    }
}

# Headers

s/^ *(#+) *(.*[^# ])[# ]*$/\1 \2/

# Make ID tag for header
h
x
s/^[# ]+ (.*[^#])[# ]*$/\L\1/
s/[^[:alnum:]]+/-/g
s/^-+|-+$//g

H
s/.*//
x

s/^#{6} (.*)\n(.*)$/<h6 id="\2">\1<\/h6>/
s/^#{5} (.*)\n(.*)$/<h5 id="\2">\1<\/h5>/
s/^#{4} (.*)\n(.*)$/<h4 id="\2">\1<\/h4>/
s/^#{3} (.*)\n(.*)$/<h3 id="\2">\1<\/h3>/
s/^#{2} (.*)\n(.*)$/<h2 id="\2">\1<\/h2>/
s/^# (.*)\n(.*)$/<h1 id="\2">\1<\/h1>/

# Clean up leftover new lines, if we get to this part there will be some left
s/\n//g
