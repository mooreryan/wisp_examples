import gleam/erlang/process
import gleam/option
import lustre/attribute
import lustre/element
import lustre/element/html
import mist
import wisp
import wisp/wisp_mist

type Context {
  /// The static assets directory on disk. Wisp will serve static assets from
  /// this directory once we configure it in the middleware.
  Context(static_directory: String)
}

/// Get the static directory name whence the static assets will be served.
fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("tailwind") |> echo
  priv_directory <> "/static"
}

pub fn main() -> Nil {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  // Put the static dir in a context structure
  let context = Context(static_directory: static_directory())

  let assert Ok(_) =
    // Need to adjust the handler to take the context
    wisp_mist.handler(handle_request(_, context), secret_key_base)
    |> mist.new
    |> mist.port(4444)
    |> mist.start

  process.sleep_forever()
}

fn handle_request(request: wisp.Request, context: Context) -> wisp.Response {
  // Context gets passed to the middleware
  use request <- middleware(request, context)

  case wisp.path_segments(request) {
    [] -> {
      let body = render_page(home_page(), title: option.None)
      wisp.html_response(body, 200)
    }

    _ -> wisp.not_found()
  }
}

fn middleware(
  request: wisp.Request,
  context: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let request = wisp.method_override(request)
  use <- wisp.log_request(request)
  use <- wisp.rescue_crashes
  use request <- wisp.handle_head(request)
  use request <- wisp.csrf_known_header_protection(request)

  // Add this to tell wisp how to serve the static assets
  use <- wisp.serve_static(
    request,
    under: "/static",
    from: context.static_directory,
  )

  handle_request(request)
}

// We will add a few tailwind and daisy classes to make sure it's working.
fn home_page() -> element.Element(a) {
  html.div([], [
    html.h1([attribute.class("text-2xl")], [
      html.text("Hello, World!"),
    ]),
    html.p([], [
      html.text("Hello from "),
      html.span([attribute.class("text-[#ffaff3]")], [html.text("Wisp!")]),
    ]),
    html.button([attribute.class("btn btn-primary")], [html.text("Click Me!")]),
  ])
}

fn layout(
  content: element.Element(a),
  title title: option.Option(String),
) -> element.Element(a) {
  let title = case title {
    option.None -> "Hello, World!"
    option.Some(title) -> title <> " | Hello, World!"
  }

  html.html([attribute.attribute("lang", "en")], [
    html.head([], [
      html.meta([attribute.charset("utf-8")]),
      html.meta([
        attribute.name("viewport"),
        attribute.content("width=device-width, initial-scale=1.0"),
      ]),
      html.title([], title),
      // We need to link to our generated CSS file
      html.link([
        attribute.rel("stylesheet"),
        // The "/static" part links up with the "under" argument of
        // wisp.serve_static.
        attribute.href("/static/css/app.css"),
      ]),
    ]),
    html.body([], [
      html.main([], [
        content,
      ]),
    ]),
  ])
}

fn render_page(
  content: element.Element(a),
  title title: option.Option(String),
) -> String {
  layout(content, title:) |> element.to_document_string
}
