{:ok, _} = Application.ensure_all_started(:wallaby)

ExUnit.configure(exclude: :browser)
ExUnit.start()
