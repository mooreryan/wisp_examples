# Static Assets & Tailwind

This example builds on the `hello_world` example by showing how to use [tailwindcss](https://tailwindcss.com/) and [daisyUI](https://daisyui.com/) with Wisp, and to do that, we also need to learn how to serve static assets.

Add Gleam packages:

```
gleam add mist wisp gleam_erlang lustre
```

Add `package.json` file:

```json
{
  "name": "tailwind-example"
}
```

Install tailwind and daisy.

```
npm i -D tailwindcss @tailwindcss/cli daisyui@latest
```

Don't forget to add `/node_modules` to your `.gitignore`!

Add an `app.css` file:

```
mkdir -p assets/css
touch assets/css/app.css
```

And put this at the top:

```css
@import "tailwindcss";
@plugin "daisyui";
```

Next, make `priv/static/css`. This is where the generated CSS file will live. Also, add the target file `/priv/static/css/app.css` to `.gitignore` since it is a generated file.

Here is something you could add to a justfile or adapt to makefile (or whatever you want to do...package.json script maybe):

```just
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
```

Rather than use tailwind's watch mode, I just stick the build script before `gleam run`. This way I can just have one single terminal managing the dev build.

Check out `./src/tailwind.gleam` ...I've (mostly) commented the changes from the `hello_world` example.
