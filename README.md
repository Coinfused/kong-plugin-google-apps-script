# Kong Plugin Google Apps Script

A Kong plugin that enables to make HTTP request to Google Apps Script API.

The plugin will execute a JSON `POST`request to the provided `script_id` with the following body:

Property | Default | Description
------------ | ------------- | -------------
`function` |  | The function specified in your settings.
`parameters` |  | An array with the arguments specified in your settings.</br>See [limitations](#limitations)
`devMode` | `false` | You can pass a boolean `devMode` as an header or a querystring.

See https://developers.google.com/apps-script/api/reference/rest/v1/scripts/run

The authentication token can be provided:

- In the upstream request header `X-Google-Token`
- With the plugin setting `config.google_service_token`
- TODO with other plugin.

## Status

Working. Still under development. See [TODO](#todo)

### TODO:

~~Add documentation about response filter (data and error).~~

~~Return `405 method not allowed` if no settings for the request method and general.~~

Handle offline scope with another plugin.

Write tests.

Publish on luarocks.

## Installation

### Development

Navigate to kong/plugins folder and clone this repo

```console
$ cd /path/to/kong/plugins
$ git clone https://github.com/Coinfused/kong-plugin-google-apps-script google-apps-script
$ cd google-apps-script
$ luarocks make *.rockspec
```

To make Kong aware that it has to look for the google-apps-script plugin, you'll have to add it to the custom_plugins property in your configuration file.

```
custom_plugins:
    - google-apps-script
```

Restart Kong and you're ready to go.

### Luarocks TODO: Not published yet.

```console
$ luarocks install kong-plugin-google-apps-script
```

## Configuration

You can add the plugin on top of a service with the following settings:

Parameter | Default | Description
------------ | ------------- | -------------
`name` |  | The name of the plugin to use, in this case: `google-apps-script`
`config.script_id` |  | The Google Apps Script scriptId to call.
`config.google_service_token` |  | The Google service token to authenticate the request.
`config.function_name` |  | The constructor for the fallback function to invoke when Kong receives a HTTP request with a method that has not a specific setting. See [details here](#function-name-and-arguments-constructor)</br>If this setting is not provided, Kong will return `405 Method Not Allowed`.
`config.function_arguments` | `method, paths, headers, querystring, body` | A comma separated list of arguments to pass to the function invoked by methods without specific settings. See [details here](#function-name-and-arguments-constructor)
`config.get.function_name` |  | The constructor for the function to invoke when Kong receives an HTTP `GET` request. See [details here](#function-name-and-arguments-constructor)
`config.get.function_arguments` | `method, paths, headers, querystring, body` | A comma separated list of arguments to pass to the function when Kong receives an HTTP `GET` request. See [details here](#function-name-and-arguments-constructor)
`config.post.function_name` |  | The constructor for the function to invoke when Kong receives an HTTP `POST` request. See [details here](#function-name-and-arguments-constructor)
`config.post.function_arguments` | `method, paths, headers, querystring, body` | A comma separated list of arguments to pass to the function when Kong receives an HTTP `POST` request. See [details here](#function-name-and-arguments-constructor)
`config.put.function_name` |  | The constructor for the function to invoke when Kong receives an HTTP `PUT` request. See [details here](#function-name-and-arguments-constructor)
`config.put.function_arguments` | `method, path, headers, querystring, body` | A comma separated list of arguments to pass to the function when Kong receives an HTTP `PUT` request. See [details here](#function-name-and-arguments-constructor)
`config.patch.function_name` |  | The constructor for the function to invoke when Kong receives an HTTP `PATCH` request. See [details here](#function-name-and-arguments-constructor)
`config.patch.function_arguments` | `method, paths, headers, querystring, body` | A comma separated list of arguments to pass to the function when Kong receives an HTTP `PATCH` request. See [details here](#function-name-and-arguments-constructor)
`config.delete.function_name` |  | The constructor for the function to invoke when Kong receives an HTTP `DELETE` request. See [details here](#function-name-and-arguments-constructor)
`config.delete.function_arguments` | `method, paths, headers, querystring, body` | A comma separated list of arguments to pass to the function when Kong receives an HTTP `DELETE` request. See [details here](#function-name-and-arguments-constructor)

#### Function name constructor and arguments constructor

Function and function arguments are defined by a comma separated list of constructors.

Each constructor is defined by a dot separated list of attributes.

When used for function name, the constructor must return a string.

Supported first attributes are:

Attribute | Description
------------ | -------------
`method` | A string representing the request method.
`paths` | A JSON object representing the matching regex paths.</br>paths.0 will return the full path of the request.</br>There can be additional properties if there is a regex setting in the associate route.
`headers` | A JSON object representing the request headers.
`querystring` | A JSON object representing the request querystring.</br>Form fields, if any, will be here.</br>Duplicate fields are passed as an array.
`body` | A JSON object representing the request body.
`fix` | A user defined static value. Mostly used for function names.

Default for function name is nil.

Default for function arguments is `method, paths, headers, querystring, body`.


## Demonstration

### 1. Google Apps Script settings.

#### 1.1 Create a script in your google account with this code:

``` javascript
function kongGet(user) {
  return {user : user};
}

function kongAny(method, paths, headers, qs, body) {
  return {
    method : method,
    paths : paths,
    headers : headers,
    qs : qs,
    body : body
  };
}

function getScriptId() {
  Logger.log(ScriptApp.getScriptId());
}
```

#### 1.2 Set the minimum scope to make the script available by API requests.

In the `appsscript.json` file add this code inside the main block:

```javascript
"oauthScopes": ["https://www.googleapis.com/auth/userinfo.email"],
```

#### 1.3 Publish the script as API executable.

In the script editor: Publish > Deploy as API executable

#### 1.4 Take note of the scriptId for Kong settings.

In the script editor: File > Project Properties > Script ID

Or: Select function > getScriptId > Run > View > Logs

### 2. Kong settings.

#### 2.1 Create the service.

```console
$ curl -X POST http://kong:8001/services/ \
  -H 'content-type: application/x-www-form-urlencoded' \
  -d 'name=users' \
  -d 'protocol=https' \
  -d 'host=script.googleapis.com' \
  -d 'port=443'
```

#### 2.2 Add a route to the service.

```console
$ curl -X POST http://kong:8001/routes \
    -H 'content-type: application/x-www-form-urlencoded' \
    -d 'paths[]=/user/(?<user>\S+)'
    -d 'protocols[]=https' \
    -d 'paths[]=/user' \
    -d 'service.id=<THE_SERVICE_ID_OF_THE_SERVICE_JUST_CREATED>'
```

#### 2.3 Add the plugin to the service.

```console
$ curl -X POST http://kong:8001/services/users/ \
    -H 'content-type: application/x-www-form-urlencoded' \
    -d 'name=google-apps-script-function' \
    -d 'config.script_id=<THE_SCIPT_ID_OF_YOUR_GOOGLE_APPS_SCRIPT>' \
    -d 'config.get.function_name=kongGet' \
    -d 'config.get.function_arguments=method,querystring.a,querystring.b,querystring.c' \
    -d 'config.function_name=kongAny'
```

### 3 Test the endpoint.

```console
$ curl -X GET http://kong:8000/users/myuser?a=a1&a=a2&c=c&devMode=true \
  -H 'authorization: Bearer <YOUR_GOOGLE_OAUTH2_TOKEN_HERE>' \
  -H 'content-type: application/x-www-form-urlencoded' \
```

```console
$ curl -X POST http://kong:8000/users/myuser \
  -H 'authorization: Bearer <YOUR_GOOGLE_OAUTH2_TOKEN_HERE>' \
  -H 'content-type: application/x-www-form-urlencoded' \
```

## Limitations

Lua does not support `null` value in arraylike table.

`null` arguments are passed as an empty string.

### Workarounds

1. Keep this in mind when writing your google apps script function.
Where checking if the argument is isNil, check for IsEmpty as well (lodash)

2. Pass arguments as object:

Instead of:

```javascript
/**
 * Log the arguments.
 *
 * @param {string}  foo
 * @param {string}  bar
 * @returns
 * @customfunction
 */
my_function(foo, bar) {
  Logger.log("foo is " + foo)
  Logger.log("bar is " + bar)
  return
}
// foo is foo
// bar is  
```

Structure your code as:

```javascript
/**
 * Log the arguments.
 *
 * @param {object}  qs
 * @returns
 * @customfunction
 */
my_function(qs) {
  Logger.log("foo is " + qs.foo)
  Logger.log("bar is " + qs.bar)
  return
}
// foo is foo
// bar is undefined
```
