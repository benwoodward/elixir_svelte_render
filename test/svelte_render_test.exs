defmodule SvelteRender.Test do
  use ExUnit.Case
  doctest SvelteRender

  setup_all do
    apply(SvelteRender, :start_link, [[render_service_path: "#{File.cwd!()}/test/fixtures"]])
    :ok
  end

  describe "get_html" do
    test "returns html" do
      {:ok, html} = SvelteRender.get_html("App.svelte", %{name: "test"})
      assert html =~ "<p>Hello from test</p>"
    end

    test "returns error when no component found" do
      {:error, error} = SvelteRender.get_html("./NotFound.svelte")
      assert error.message =~ "Cannot find module"
    end
  end
end
