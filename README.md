MackerelAppActivity.app
===

Post the number of key types for each application to [mackerel.io](https://mackerel.io/) as ServiceMetric

Inspired from http://songmu.github.io/slides/mackerel-3/#0

## Installation

### Download Application

TODO

### `~/.mackerel-app-activity.json`

```js
{
    "ApiKey": "hogehogefugafugapiyopiyo", // your api key
    "ServiceName": "clients", // your service name
    "MetricPrefix": "activity.types.", // set graph group name

    // A default metric name is last part of `BundlerIdentifier`.
    // (e.g `com.pokutuna.MackerelAppActivity` -> `MackerelAppActivity`)
    // Define mappings if you want to rename a metric name
    "NameMapping": {
        "slackmacgap": "Slack",
        "LimeChat-AppStore": "LimeChat",
        "keychainaccess": "" // Set an empty string to avoid posting as metric
    },

    "PostIntervalMinutes": 1
}
```

### Enable Accesibility

- open `System Preferences` > `Security & Privacy`
- click the lock icon to change settings
- select `Accesibility` from the left list
- drag and drop the app to the left list
- check its checkbox
