# fluent-plugin-ruby_one_liner

Run ruby one line of script in this plugin.

## Input Plugin

````
<source>
  type ruby_one_liner
  require_libs open-uri
  command Engine.emit('hoge',Engine.now,{'hoge' => @config['any_config']})
  run_interval 120
  any_config 2
</source>

<match hoge.**>
  type stdout
</match>
````

````
2014-02-03 00:38:58 +0900 hoge: {"hoge":"2"}
````

## Output Plugin

````
<source>
  type exec
  command echo http://example.com
  keys uri
  tag example
  run_interval 5s
</source>

<match example.**>
  type ruby_one_liner
  require_libs open-uri
  command  puts time; puts record['uri']; puts @config['any_config']
  run_interval 120
  any_config 2
</match>
````

````
1397928852
http://example.com
2
````
