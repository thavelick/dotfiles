# LLM code function
if command_exists llm; then
    llmc() {
        local code=$(llm -s 'code in zsh for archlinux. Keep it as simple and brief as possible. Output only the code requested, no commentary. No shebang. Only one example.' --xl "$@" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        print -z "$code"
    }
fi

# Summary function with dependencies
if command_exists curl && command_exists llm && command_exists pandoc && command_exists firefox; then
    summary() {
        curl -s "https://r.jina.ai/$1" | llm "summarize this text" | pandoc -f markdown -t html > /tmp/summary.html && firefox /tmp/summary.html
    }
fi

# QR code paste function
qr-paste() {
    local paste_cmd=$(get_clipboard_paste_cmd)
    if command_exists qrencode && command_exists imv; then
        $paste_cmd | qrencode -o - -t PNG | imv -
    else
        echo "qr-paste requires qrencode and imv to be installed"
    fi
}

# Dictionary function
if command_exists sdcv && command_exists elinks && command_exists less; then
    def() {
        sdcv -n --utf8-output "$@" 2>&1 | sed 's/-->/<p>-->/g' | elinks -dump | less -EXFRfM
    }
fi

# Unicode clipboard function
if command_exists fzf; then
    uniclip() {
        local clipboard_cmd=$(get_clipboard_copy_cmd)
        cat $DOTFILES_HOME/zsh/latex_symbols.txt 2>/dev/null | fzf --query $1 | tr -s ' ' | cut -d ' ' -f2 | tr -d "\n" | $clipboard_cmd
    }
fi


# Question function for web content
if command_exists curl && command_exists llm; then
    q() {
        local url="$1"
        local question="$2"

        # Fetch the URL content through Jina
        local content=$(curl -s "https://r.jina.ai/$url")

        # Check if the content was retrieved successfully
        if [ -z "$content" ]; then
            echo "Failed to retrieve content from the URL."
            return 1
        fi

        system="
        You are a helpful assistant that can answer questions about the content.
        Reply concisely, in a few sentences.

        The content:
        ${content}
        "

        # Use llm with the fetched content as a system prompt
        llm prompt "$question" -s "$system"
    }
fi

# Video question function
if command_exists yt-dlp && command_exists curl && command_exists llm; then
    qv() {
        local url="$1"
        local question="$2"

        # Fetch the URL content through Jina
        local subtitle_url=$(yt-dlp -q --skip-download --convert-subs srt --write-sub --sub-langs "en" --write-auto-sub --print "requested_subtitles.en.url" "$url")
        local content=$(curl -s "$subtitle_url" | sed '/^$/d' | grep -v '^[0-9]*$' | grep -v '\-->' | sed 's/<[^>]*>//g' | tr '\n' ' ')

        # Check if the content was retrieved successfully
        if [ -z "$content" ]; then
            echo "Failed to retrieve content from the URL."
            return 1
        fi
    }
fi

function -() {
    cd -
}
