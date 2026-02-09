# Client Side Form Validation

This is a simple example of using the [browser's built-in form validation](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Forms/Form_validation#using_built-in_form_validation).

You should validate form data on the server as well, but that's not what this example is about.

It's going to use tailwind and daisyUI for styling, so you may want to check out the tailwind example first for how to get that set up.

## Required Packages

Gleam packages:

- mist
- wisp
- gleam_erlang
- lustre

NPM packages:

- tailwindcss
- @tailwindcss/cli
- daisyui@latest

## Notes

- Make sure you wrap the label+input+span trio inside of some other element so that the validation errors only show for their specific inputs!

## See Also

Daisy UI docs:

- [Input fields](https://daisyui.com/components/input/)
- [Textarea](https://daisyui.com/components/textarea/)
- [Validator]([Validator](https://daisyui.com/components/validator/)
