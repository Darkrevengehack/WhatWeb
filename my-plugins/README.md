# Custom Plugins Directory

Place your custom WhatWeb plugins here.

## Creating a Custom Plugin

```ruby
Plugin.define do
  name "MyPlugin"
  author "Your Name"
  version "1.0"
  description "Description of what it detects"
  
  # Detection rules
  matches [
    { :text => "some string to detect" }
  ]
end
```

## Using Custom Plugins

```bash
./whatweb -p +my-plugins/myplugin.rb example.com
```

See [plugin-development/](../plugin-development/) for more examples.
