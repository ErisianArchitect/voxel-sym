
function build() {
    zig build
}

function run() {
    zig build run "$@"
}

function update-subs() {
    git --git-dir ./build_tools/.git pull origin main
}

declare -Arg dep_aliases=(
    [coreo]='zig fetch --save "git+$(ghl -ng coreo)"'
    [build_tools]='git --git-dir ./build_tools/.git pull origin main'
)

function update-dep() {
    eval "${dep_aliases[$1]}"
}

function update-deps() {
    local only_self=0
    case "$1" in
        -s|--self) only_self=1 ;;
        -e|--exact)
            ;;
    esac
    update-dep coreo
    update-dep build_tools
    if ! (( only_self )); then
        : # Add external dependencies here.
    fi
}
