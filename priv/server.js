require('svelte/register');

function deleteCache(componentPath) {
  if (
    process.env.NODE_ENV !== 'production' &&
    require.resolve(componentPath) in require.cache
  ) {
    delete require.cache[require.resolve(componentPath)]
  }
}

function requireComponent(componentPath) {
  // remove from cache in non-production environments
  // so that we can see changes
  deleteCache(componentPath)

  return require(componentPath).default
}

function render(componentPath, props) {
  try {
    const component = requireComponent(componentPath)

    const { html, css, head } = component.render(props);

    const response = {
      error: null,
      markup: html
    }

    return response
  } catch (err) {
    const response = {
      path: componentPath,
      error: {
        type: err.constructor.name,
        message: err.message,
        stack: err.stack,
      },
      markup: null,
      component: null,
    }

    return response
  }
}

module.exports = {
  render,
}
