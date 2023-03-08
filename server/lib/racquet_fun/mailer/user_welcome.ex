defmodule RacquetFun.Mailer.UserWelcome do
  use Phoenix.Swoosh,
    template_root: "lib/racquet_fun/mailer",
    template_path: "user_welcome"

  def build({name, email} = to, %{activation_id: activation_id}) do
    link =
      RacquetFunWeb.Endpoint.url()
      |> URI.merge("api/auth/activate")
      |> URI.merge("?email=#{email}&activation_id=#{activation_id}")
      |> URI.to_string()

    new()
    |> to(to)
    # fixme: configure
    |> from({"Dr B Banner", "hulk.smash@example.com"})
    |> subject("Welcome, #{name}}!")
    |> render_body("user_welcome.html", %{name: name, link: link})
  end
end
