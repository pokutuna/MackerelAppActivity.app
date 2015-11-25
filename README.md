MackerelAppActivity.app
===

Post the number of key types for each application to [mackerel.io](https://mackerel.io/) as ServiceMetric

Inspired from http://songmu.github.io/slides/mackerel-3/#0

![activity_graph](https://raw.githubusercontent.com/pokutuna/MackerelAppActivity.app/master/resources/activity_graph.png)


## Installation

### Download Application

[MackerelAppActivity.app](https://github.com/pokutuna/MackerelAppActivity.app/raw/master/releases/MackerelAppActivity-1.2.app.zip)

### Put `~/.mackerel-app-activity.json`

```js
{
    "ApiKey": "hogehogefugafugapiyopiyo",
    "ServiceName": "clients", // your service name in mackerel.io
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

### Enable Accessibility

OS X requires `Accessibility` for monitoring global key events.

- open `System Preferences` > `Security & Privacy`
- click the lock icon to change settings
- select `Accessibility` from the left list
- drag and drop the app to the right list
- check its checkbox

![goal](https://raw.githubusercontent.com/pokutuna/MackerelAppActivity.app/master/resources/accessibility.png)
