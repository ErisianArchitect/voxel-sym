
function build() {
    zig build
}

function run() {
    zig build run "$@"
}

function update-submodules() {
    git --git-dir ./build_tools/.git pull origin main
}
