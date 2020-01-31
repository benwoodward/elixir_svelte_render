# SvelteRender

[![Hex.pm](https://img.shields.io/hexpm/dt/svelte_render.svg)](https://hex.pm/packages/svelte_render)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Renders Svelte as HTML

## Documentation

The docs can
be found at [https://hexdocs.pm/svelte_render](https://hexdocs.pm/svelte_render).

## Installation

```elixir
def deps do
  [
    {:svelte_render, "~> 3.0.0"}
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
  require('@babel/polyfill')
  require('@babel/register')({cwd: __dirname})

  module.exports = require('svelte_render/priv/server')
  ```

  Note: You must move any `@babel` used for server-side rendering from `devDependencies` to `dependencies` in your `package.json` file. This is required when installing dependencies required for production as these packages.

- Add `SvelteRender` to your Supervisor as a child. We're using the absolute path to ensure we are specifying the correct working directory that contains the `render_server.js` file we created earlier.

  ```elixir
    render_service_path = "#{File.cwd!}/assets"
    pool_size = 4

    supervisor(SvelteRender, [[render_service_path: render_service_path, pool_size: 4]])
  ```

- Create a svelte component like:

  ```js
  import Svelte, {Component, createElement} from 'svelte'

  class HelloWorld extends Component {
    render() {
      const {name} = this.props

      return <div>Hello {name}</div>
    }
  }

  export default HelloWorld
  ```

- Call `SvelteRender.render/2` inside the action of your controller

  ```elixir
  def index(conn, _params) do
    component_path = "#{File.cwd!}/assets/js/HelloWorld.js"
    props = %{name: "Revelry"}

    { :safe, helloWorld } = SvelteRender.render(component_path, props)

    render(conn, "index.html", helloWorldComponent: helloWorld)
  end
  ```

  `component_path` can either be an absolute path or one relative to the render service. The stipulation is that components must be in the same path or a sub directory of the render service. This is so that the babel compiler will be able to compile it. The service will make sure that any changes you make are picked up. It does this by removing the component_path from node's `require` cache. If do not want this to happen, make sure to add `NODE_ENV` to your environment variables with the value `production`.

- Render the component in the template

  ```elixir
  <%= raw @helloWorldComponent %>
  ```

- To hydrate server-created components in the client, add the following to your `app.js`

  ```js
  import {hydrateClient} from 'svelte_render/priv/client'
  import HelloWorld from './HelloWorld.js'

  function getComponentFromStringName(stringName) {
    // Map string component names to your svelte components here
    if (stringName === 'HelloWorld') {
      return HelloWorld
    }

    return null
  }

  hydrateClient(getComponentFromStringName)
  ```

- Update `assets/webpack.config` to include under the `resolve` section so that module resolution is handled properly:

  ```
  resolve: {
    symlinks: false
  }
  ```
