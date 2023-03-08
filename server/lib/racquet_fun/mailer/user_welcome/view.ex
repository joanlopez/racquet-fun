defmodule RacquetFun.Mailer.UserWelcome.View do
  use Phoenix.Swoosh,
    template_root: "lib/racquet_fun/mailer",
    template_path: "user_welcome"
end
