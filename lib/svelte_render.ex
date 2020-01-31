defmodule SvelteRender do
  use Supervisor

  @timeout 10_000
  @default_pool_size 4

  @moduledoc """
  Svelte Renderer
  """

  @doc """
  Starts the SvelteRender and workers.

  ## Options
    * `:render_service_path` - (required) is the path to the svelte render service relative
  to your current working directory
    * `:pool_size` - (optional) the number of workers. Defaults to 4
  """
  @spec start_link(keyword()) :: {:ok, pid} | {:error, any()}
  def start_link(args) do
    default_options = [pool_size: @default_pool_size]
    opts = Keyword.merge(default_options, args)

    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Stops the SvelteRender and underlying node svelte render service
  """
  @spec stop() :: :ok
  def stop() do
    Supervisor.stop(__MODULE__)
  end

  @doc """
  Given the `component_path` and `props`, returns html.

  `component_path` is the path to your svelte component module relative
  to the render service.

  `props` is a map of props given to the component. Must be able to turn into
  json
  """
  @spec get_html(binary(), map()) :: {:ok, binary()} | {:error, map()}
  def get_html(component_path, props \\ %{}) do
    case do_get_html(component_path, props) do
      {:error, _} = error ->
        error

      {:ok, %{"markup" => markup}} ->
        {:ok, markup}
    end
  end

  @doc """
  Same as `get_html/2` but wraps html in a div which is used
  to hydrate svelte component on client side.

  This is the preferred function when using with Phoenix

  `component_path` is the path to your svelte component module relative
  to the render service.

  `props` is a map of props given to the component. Must be able to turn into
  json
  """
  @spec render(binary(), map()) :: {:safe, binary()}
  def render(component_path, props \\ %{}) do
    case do_get_html(component_path, props) do
      {:error, %{message: message, stack: stack}} ->
        raise SvelteRender.RenderError, message: message, stack: stack

      {:ok, %{"markup" => markup}} ->
        props =
          props
          |> Jason.encode!()
          |> String.replace("\"", "&quot;")

        html =
          """
          #{markup}
          """
          |> String.replace("\n", "")

        {:safe, html}
    end
  end

  defp do_get_html(component_path, props) do
    task =
      Task.async(fn ->
        NodeJS.call({:render_server, :render}, [component_path, props], binary: true)
      end)

    case Task.await(task, @timeout) do
      {:ok, %{"error" => error}} when not is_nil(error) ->
        normalized_error = %{
          message: error["message"],
          stack: error["stack"]
        }

        {:error, normalized_error}

      {:ok, result} ->
        {:ok, result}
    end
  end

  # --- Supervisor Callbacks ---
  @doc false
  def init(opts) do
    pool_size = Keyword.fetch!(opts, :pool_size)
    render_service_path = Keyword.fetch!(opts, :render_service_path)

    children =
      case Application.get_application(:nodejs) do
        nil ->
          [
            supervisor(NodeJS.Supervisor, [
              [path: render_service_path, pool_size: pool_size]
            ])
          ]

        _ ->
          []
      end

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
