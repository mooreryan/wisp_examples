hello_world_dev:
    cd hello_world && \
    watchexec \
        --debounce 500ms \
        --restart \
        --watch src \
        --watch test \
        --watch gleam.toml \
        -- 'sleep 2 && gleam run'

hello_world:
    cd hello_world && gleam run

tailwind_dev:
    cd tailwind && \
    watchexec \
        --debounce 500ms \
        --restart \
        --watch src \
        --watch test \
        --watch assets \
        --watch gleam.toml \
        -- 'sleep 2 && npx @tailwindcss/cli -i ./assets/css/app.css -o ./priv/static/css/app.css && gleam run'

tailwind:
    cd tailwind && npx @tailwindcss/cli -i ./assets/css/app.css -o ./priv/static/css/app.css --minify && gleam run
