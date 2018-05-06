package = "kong-plugin-google-apps-script"
version = "0.1.0-1"
-- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

-- TODO: This is the name to set in the Kong configuration `custom_plugins` setting.
-- Here we extract it from the package name.
local pluginName = package:match("^kong%-plugin%-(.+)$")  -- "myPlugin"

supported_platforms = {"linux", "macosx"}
source = {
  -- these are initially not required to make it work
  url = "git://github.com/Coinfused/kong-plugin-google-apps-script",
  tag = "0.1.0"
}

description = {
  summary = "A Kong plugin that allows to call google apps script functions and libaries.",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "array >=1.2"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.google-apps-script.access"] = "kong/plugins/google-apps-script/access.lua",
    ["kong.plugins.google-apps-script.body_filter"] = "kong/plugins/google-apps-script/body_filter.lua",
    ["kong.plugins.google-apps-script.gas"]  = "kong/plugins/google-apps-script/gas.lua",
    ["kong.plugins.google-apps-script.handler"] = "kong/plugins/google-apps-script/handler.lua",
    ["kong.plugins.google-apps-script.schema"]  = "kong/plugins/google-apps-script/schema.lua",
  }
}
