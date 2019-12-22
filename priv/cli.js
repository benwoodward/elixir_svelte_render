// This interface allows you to use console.log statements in server.js (which otherwise
// interfere with the readline interface that elixir-nodejs uses)
//
// node priv/cli --component "/Full/path/to/Component.svelte" --props "{name: 'Svelte'}"
// output:
//   { error: null,
//      markup: '<p>Hello from Svelte</p>',
//      component: '/Users/you/Dev/project_folder/assets/src/Component.svelte' }


const render = require('./server.js').render
const args = require('minimist')(process.argv.slice(2))
const componentPath = args['component']
const props = args['props'];

console.log(render(componentPath, props));
console.log(args['props'])
