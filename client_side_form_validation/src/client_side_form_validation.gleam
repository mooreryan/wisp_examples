import gleam/erlang/process
import gleam/option
import lustre/attribute
import lustre/element
import lustre/element/html
import mist
import wisp
import wisp/wisp_mist

type Context {
  Context(static_directory: String)
}

fn static_directory() -> String {
  let assert Ok(priv_directory) =
    wisp.priv_directory("client_side_form_validation") |> echo
  priv_directory <> "/static"
}

pub fn main() -> Nil {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  let context = Context(static_directory: static_directory())

  let assert Ok(_) =
    wisp_mist.handler(handle_request(_, context), secret_key_base)
    |> mist.new
    |> mist.port(4444)
    |> mist.start

  process.sleep_forever()
}

fn handle_request(request: wisp.Request, context: Context) -> wisp.Response {
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

  use <- wisp.serve_static(
    request,
    under: "/static",
    from: context.static_directory,
  )

  handle_request(request)
}

fn home_page() -> element.Element(a) {
  html.div([], [
    html.h1([attribute.class("text-2xl")], [
      html.text("Client-Side Form Validation!"),
    ]),
    form_view(),
  ])
}

fn form_view() {
  html.form([], [
    html.fieldset(
      [
        attribute.class(
          "fieldset bg-base-200 border-base-300 rounded-box w-xs border p-4",
        ),
      ],
      [
        html.legend([attribute.class("fieldset-legend")], [
          html.text("Leave a review!"),
        ]),

        html.div([], [
          html.label([attribute.for("title"), attribute.class("label")], [
            html.text("Title"),
          ]),
          html.input([
            attribute.type_("text"),
            attribute.name("title"),
            attribute.id("title"),
            attribute.required(True),
            attribute.minlength(2),
            attribute.maxlength(64),
            attribute.class("input validator"),
          ]),
          html.span([attribute.class("validator-hint font-bold")], [
            html.text("⚠️ Must be between 2 and 64 characters"),
          ]),
        ]),

        html.div([], [
          html.label([attribute.for("review"), attribute.class("label")], [
            html.text("Review"),
          ]),
          html.textarea(
            [
              attribute.name("review"),
              attribute.id("review"),
              attribute.required(False),
              attribute.minlength(5),
              attribute.maxlength(256),
              attribute.class("textarea validator"),
            ],
            "",
          ),
          html.span([attribute.class("validator-hint font-bold")], [
            html.text("⚠️ Must be between 5 and 256 characters"),
          ]),
        ]),

        html.button(
          [attribute.type_("submit"), attribute.class("btn btn-primary mt-4")],
          [html.text("Submit")],
        ),
        html.button(
          [attribute.type_("reset"), attribute.class("btn btn-ghost mt-1")],
          [html.text("Cancel")],
        ),
      ],
    ),
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
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/css/app.css"),
      ]),
    ]),
    html.body([], [
      html.main([attribute.class("container mx-auto pt-4")], [
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
