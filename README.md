# SvelteRender

[![Hex.pm](https://img.shields.io/hexpm/dt/svelte_render.svg)](https://hex.pm/packages/svelte_render)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

WARNING: This is beta. Don't use in production unless you know what you're doing!

Renders Svelte components as HTML

## Documentation

The docs can
be found at [https://hexdocs.pm/svelte_render](https://hexdocs.pm/svelte_render).

## Installation

```elixir
def deps do
  [
    {:svelte_render, "~> 0.1.0"}
  ]
end
```

## Getting Started with Phoenix

- Add `svelte_render` to your dependencies in package.json

  ```js
  "svelte_render": "file:../deps/svelte_render"
  ```

- Run `npm install`

  ```bash
  npm install
  ```

- Create a file named `render_server.js` in your `assets` folder and add the following

  ```js
  module.exports = require('svelte_render/priv/server')
  ```

- Add `SvelteRender` to your Supervisor as a child. We're using the absolute path to ensure we are specifying the correct working directory that contains the `render_server.js` file we created earlier.

  ```elixir
    children = [
      %{
        id: SvelteRender,
        start:
          {SvelteRender, :start_link, [[render_service_path: render_service_path, pool_size: 4]]},
        type: :supervisor
      }
    ]
  ```

- Create a svelte component like:

  ```js
  <script>
  export let params;
  </script>

  <p>Hello from {name}</p>

  <style>
  p {
    font-weight: normal;
  }
  </style>

  ```

- Call `SvelteRender.render/2` inside the action of your controller

  ```elixir
  def index(conn, _params) do
    component_path = "#{File.cwd!()}/assets/src/components/HelloWorld.svelte"
    props = %{params: %{name: "Phoenix"}}

    {:safe, helloWorld} = SvelteRender.render(component_path, props)

    render(conn, "index.html", helloWorldComponent: helloWorld)
  end
  ```

  `component_path` can either be an absolute path or one relative to the render service. The stipulation is that components must be in the same path or a sub directory of the render service. This is so that the babel compiler will be able to compile it. The service will make sure that any changes you make are picked up. It does this by removing the component_path from node's `require` cache. If do not want this to happen, make sure to add `NODE_ENV` to your environment variables with the value `production`.

- Render the component in the template

  ```elixir
  <%= raw @helloWorldComponent %>
  ```

- To add routing for your components, create a base component, e.g. assets/src/App.svelte and use page.js

Taken from: [https://jackwhiting.co.uk/posts/setting-up-routing-in-svelte-with-pagejs/](https://jackwhiting.co.uk/posts/setting-up-routing-in-svelte-with-pagejs/)

  ```js
  <script>
    import router from 'page';
    import Home from './routes/Home.svelte';

    let page;
    let params = {name: "svelte"};

    router('/', () => page = Home)

    router.start();
  </script>

  <svelte:component this={page} params={params} />
  ```

- To hydrate server-created components in the client, add the following to your `app.js`

  ```js
  import App from './components/App.svelte';
  window.app = new App({
    target: document.querySelector('#svelte'),
    hydrate: true
  });
  ```

- Example rollup config:

The postcss configs allow you to import a global.scss file into your App.svelte like so:

  ```css
  <style global type="scss" >
    @import "../styles/global.scss";
  </style>
  ```


  ```js
  import svelte from 'rollup-plugin-svelte';
  import resolve from '@rollup/plugin-node-resolve';
  import commonjs from '@rollup/plugin-commonjs';
  import { terser } from 'rollup-plugin-terser';
  import sveltePreprocess from 'svelte-preprocess';

  const production = !process.env.ROLLUP_WATCH;
  const preprocess = sveltePreprocess({
    scss: {
      includePaths: ['src'],
    },
    postcss: {
      plugins: [require('postcss-import')({path: ['src/styles']})],
    },
  });

  export default {
    input: 'src/app.js',
    output: {
      sourcemap: true,
      format: 'iife',
      name: 'app',
      file: '../priv/static/js/app.js'
    },
    plugins: [
      svelte({
        hydratable: true,

        // enable run-time checks when not in production
        dev: !production,
        preprocess,

        css: css => {
          css.write('../priv/static/css/app.css');
        }
      }),

      resolve({
        browser: true,
        // a dependency in node_modules may have svelte inside it's node_modules folder
        // dedupe option prevents bundling those duplicates
        dedupe: ['svelte']

      }),
      commonjs(),

      // If we're building for production (npm run build
      // instead of npm run dev), minify
      production && terser()
    ],
    watch: {
      clearScreen: false
    }
  };
  ```

- Add rollup to your list of watchers in `config/dev.exs`

  ```elixir
  config :your_app, YourApp.Endpoint,
    http: [port: 4000],
    debug_errors: true,
    code_reloader: true,
    check_origin: false,
    watchers: [
      rollup: [
        "--config",
        "--watch",
        cd: Path.expand("../assets", __DIR__)
      ]
    ]
  ```

You should now be able to run `mix phx.server` and your Svelte components with update with live reloading

## Development

For debugging you can use `priv/cli.js`:

```js
node priv/cli --component "/Full/path/to/Component.svelte" --props "{name: 'Svelte'}"
// output:
//   { error: null,
//      markup: '<p>Hello from Svelte</p>',
//      component: '/Users/you/Dev/project_folder/assets/src/Component.svelte' }
```
