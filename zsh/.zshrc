# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Load environment variables from a file
source ~/.keys

# Suggestion Strategy
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="simple"
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Sets the terminal title to fixed value.
# print -Pn "\e]0;Terminal\e\\"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	sudo 
	fzf
	zsh-syntax-highlighting
	dotenv
)

# FZF loaded - Ctrl + R (recall history) and Ctrl + T (traverse files)
source $ZSH/oh-my-zsh.sh
source <(fzf --zsh)
export FZF_BASE="/opt/homebrew/Cellar/fzf"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# You may need to manually set your language environment
export LANG=en_NZ.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='code'
else
  export EDITOR='code'
fi

# Aider Default
export AIDER_EDITOR="code --wait"

# param function for mkv2mp4 Remux
mkv2mp4() {
    ffmpeg -codec copy 'output.mp4' -i $1
}
# param function for convertmp4
convertmp4() {
    ffmpeg -crf 18 -c:a aac 'converted.mp4' -i $1
}

kimi() {
	export ANTHROPIC_BASE_URL=https://api.moonshot.ai/anthropic
	export ANTHROPIC_AUTH_TOKEN=$KIMI_API_KEY
	claude $1
}


# Suggest GitHub Copilot - ghcs
ghcs() {
	FUNCNAME="$funcstack[1]"
	TARGET="shell"
	local GH_DEBUG="$GH_DEBUG"

	read -r -d '' __USAGE <<-EOF
	Wrapper around \`gh copilot suggest\` to suggest a command based on a natural language description of the desired output effort.
	Supports executing suggested commands if applicable.

	USAGE
	  $FUNCNAME [flags] <prompt>

	FLAGS
	  -d, --debug              Enable debugging
	  -h, --help               Display help usage
	  -t, --target target      Target for suggestion; must be shell, gh, git
	                           default: "$TARGET"

	EXAMPLES

	- Guided experience
	  $ $FUNCNAME

	- Git use cases
	  $ $FUNCNAME -t git "Undo the most recent local commits"
	  $ $FUNCNAME -t git "Clean up local branches"
	  $ $FUNCNAME -t git "Setup LFS for images"

	- Working with the GitHub CLI in the terminal
	  $ $FUNCNAME -t gh "Create pull request"
	  $ $FUNCNAME -t gh "List pull requests waiting for my review"
	  $ $FUNCNAME -t gh "Summarize work I have done in issues and pull requests for promotion"

	- General use cases
	  $ $FUNCNAME "Kill processes holding onto deleted files"
	  $ $FUNCNAME "Test whether there are SSL/TLS issues with github.com"
	  $ $FUNCNAME "Convert SVG to PNG and resize"
	  $ $FUNCNAME "Convert MOV to animated PNG"
	EOF

	local OPT OPTARG OPTIND
	while getopts "dht:-:" OPT; do
		if [ "$OPT" = "-" ]; then     # long option: reformulate OPT and OPTARG
			OPT="${OPTARG%%=*}"       # extract long option name
			OPTARG="${OPTARG#"$OPT"}" # extract long option argument (may be empty)
			OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
		fi

		case "$OPT" in
			debug | d)
				GH_DEBUG=api
				;;

			help | h)
				echo "$__USAGE"
				return 0
				;;

			target | t)
				TARGET="$OPTARG"
				;;
		esac
	done

	# shift so that $@, $1, etc. refer to the non-option arguments
	shift "$((OPTIND-1))"

	TMPFILE="$(mktemp -t gh-copilotXXX)"
	trap 'rm -f "$TMPFILE"' EXIT
	if GH_DEBUG="$GH_DEBUG" gh copilot suggest -t "$TARGET" "$@" --shell-out "$TMPFILE"; then
		if [ -s "$TMPFILE" ]; then
			FIXED_CMD="$(cat $TMPFILE)"
			print -s "$FIXED_CMD"
			echo
			eval "$FIXED_CMD"
		fi
	else
		return 1
	fi
}

# Explain GitHub Copilot - ghce
ghce() {
	FUNCNAME="$funcstack[1]"
	local GH_DEBUG="$GH_DEBUG"

	read -r -d '' __USAGE <<-EOF
	Wrapper around \`gh copilot explain\` to explain a given input command in natural language.

	USAGE
	  $FUNCNAME [flags] <command>

	FLAGS
	  -d, --debug   Enable debugging
	  -h, --help    Display help usage

	EXAMPLES

	# View disk usage, sorted by size
	$ $FUNCNAME 'du -sh | sort -h'

	# View git repository history as text graphical representation
	$ $FUNCNAME 'git log --oneline --graph --decorate --all'

	# Remove binary objects larger than 50 megabytes from git history
	$ $FUNCNAME 'bfg --strip-blobs-bigger-than 50M'
	EOF

	local OPT OPTARG OPTIND
	while getopts "dh-:" OPT; do
		if [ "$OPT" = "-" ]; then     # long option: reformulate OPT and OPTARG
			OPT="${OPTARG%%=*}"       # extract long option name
			OPTARG="${OPTARG#"$OPT"}" # extract long option argument (may be empty)
			OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
		fi

		case "$OPT" in
			debug | d)
				GH_DEBUG=api
				;;

			help | h)
				echo "$__USAGE"
				return 0
				;;
		esac
	done

	# shift so that $@, $1, etc. refer to the non-option arguments
	shift "$((OPTIND-1))"

	GH_DEBUG="$GH_DEBUG" gh copilot explain "$@"
}

# Convert MKV to MP4
mkv2mp3() {

	filename=$1  # Replace with your actual filename
	extension="${filename##*.}"
	basename="${filename%.*}"
	temp_outputfile="${basename}_temp.${extension}"

	ffmpeg -i "$filename" -q:a 0 -map a "$temp_outputfile" && mv "$temp_outputfile" "$basename.mp3"
}

# Convert MKV to MP4
mkv2mp4() {

	filename=$1  # Replace with your actual filename
	extension="${filename##*.}"
	basename="${filename%.*}"
	temp_outputfile="${basename}_temp.${extension}"

	ffmpeg -i "$filename" -codec copy "$temp_outputfile" && mv "$temp_outputfile" "$basename.mp4"
}

# Convert MKV to MOV
mkv2mov() {
	# Use the current directory as input and output directory
	INPUT_DIR=$(pwd)
	OUTPUT_DIR=$INPUT_DIR

	# Loop over all MKV files in the input directory
	for input_file in "$INPUT_DIR"/*.mkv; do
	  # Get the base name of the file (without path and extension)
	  base_name=$(basename "$input_file" .mkv)
	  # Construct the output file name
	  output_file="$OUTPUT_DIR/${base_name}.mov"
  
	  # Run ffmpeg to remux the file
	  ffmpeg -i "$input_file" -map 0 -c copy "$output_file"
  
	  # Check if ffmpeg command was successful
	  if [ $? -eq 0 ]; then
	    echo "Successfully converted: $input_file to $output_file"
	  else
	    echo "Failed to convert: $input_file" >&2
	  fi
	done
}

# Convert MKV to DNxHD
mkv2dnxhd() {
	# Use the current directory as input and output directory
	INPUT_DIR=$(pwd)
	OUTPUT_DIR=$INPUT_DIR

	# Bitrate for DNxHD
	BITRATE="120M"

	# Loop over all MKV files in the input directory
	for input_file in "$INPUT_DIR"/*.mkv; do
	  # Get the base name of the file (without path and extension)
	  base_name=$(basename "$input_file" .mkv)
	  # Construct the output file name
	  output_file="$OUTPUT_DIR/${base_name}.mov"
  
	  # Run ffmpeg to convert the file
	  ffmpeg -i "$input_file" -c:v dnxhd -b:v "$BITRATE" -c:a pcm_s16le "$output_file"
  
	  # Check if ffmpeg command was successful
	  if [ $? -eq 0 ]; then
	    echo "Successfully converted: $input_file to $output_file"
	  else
	    echo "Failed to convert: $input_file" >&2
	  fi
	done
}

# Parse URL to return content LLM and MD ready
parseUrl() {
	curl "https://r.jina.ai/$1"
}

# Merge audio and video files
mav() {
	ffmpeg -i $1 -i $2 -c copy -map 0:v:0 -map 1:a:0 $3
}

# Open Dash with query
dash() {
	open "dash://?query=$1"
}
# Set Node.js compile cache
# https://www.perplexity.ai/search/2862adcb-7b89-4864-88d3-b42231532df4
export NODE_COMPILE_CACHE="/tmp/node-compile-cache"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
# ==============================================================
# Aliases
# yt-dlp aliases
alias ytmp4="yt-dlp -f 'bv[height=1080][ext=mp4]+ba[ext=m4a]' --merge-output-format mp4 "
alias ytmp3="yt-dlp -x --add-metadata --compat-options embed-metadata --audio-format mp3 -o '%(playlist_index)s - %(artist)s - %(title)s.%(ext)s'"
alias ytm4a="yt-dlp -x --add-metadata --compat-options embed-metadata --audio-format m4a -o '%(playlist_index)s - %(artist)s - %(title)s.%(ext)s'"

# mongoDB alias to run in docker
alias monogoup="docker run -d \
  --name mongodb \
  -p 27017:27017 \
  -v mongodb_data:/data/db \
  --restart unless-stopped \
  mongo:latest"

# postgres alias to run in docker
alias postgresup="docker run --name postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_DB=postgres \
  -p 5432:5432 \
  -v postgres-data:/var/lib/postgresql/data \
  -d postgres:latest"

# openwebui alias to run in docker
alias openwebui="docker run -d \
  -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name openwebui \
  --restart always \
  ghcr.io/open-webui/open-webui:main"

# update ollama models
alias oupdate="ollama list | awk 'NR>1 {print \$1}' | xargs -I {} sh -c 'echo Updating model: {}; ollama pull {}; echo --' && echo All models updated."
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'

# pyenv - nvm for python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# ollama allow access from all hosts
export OLLAMA_HOST="0.0.0.0"

# ollama api base
export OLLAMA_API_BASE=http://127.0.0.1:11434 # Mac/Linux

#export OLLAMA_ORIGINS=moz-extension://*

# Aider default
# export AIDER_MODEL=ollama/qwen2.5-coder:14b
# export AIDER_MODEL=ollama/deepseek-r1:14b
export AIDER_MODEL=deepseek/deepseek-chat
# export AIDER_MODEL=gemini/gemini-2.5-pro-preview-03-25

# Enable syntax highlighting in zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Hide name & host in terminal
prompt_context(){}

# prompt directory styling
prompt_dir() {
  prompt_segment blue black "${PWD##*/}"
}

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"


test -e "$HOME/.shellfishrc" && source "$HOME/.shellfishrc"
