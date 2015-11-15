MackerelAppActivity.app
===

Post the number of key types for each application to [mackerel.io](https://mackerel.io/) as ServiceMetric

Inspired from http://songmu.github.io/slides/mackerel-3/#0

## Installation

### Download Application

TODO

### Put `~/.mackerel-app-activity.json`

```js
{
    "ApiKey": "hogehogefugafugapiyopiyo",
    "ServiceName": "clients", // your service name
    "MetricPrefix": "activity.types.", // set a graph name prefix

    // A default metric name is the last part of `BundlerIdentifier`.
    //   (e.g `com.pokutuna.MackerelAppActivity` -> `MackerelAppActivity`)
    // Define mappings if you want to rename metric
    "NameMapping": {
        "slackmacgap": "Slack",
        "LimeChat-AppStore": "LimeChat",
        "keychainaccess": "" // Set an empty string to avoid posting
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
