Send all the activity in your Github repo to Keen IO
----



Overview
----
Keen IO allows you to gather data from different places and consume it in a very easy way using their APIs. This middleware modifies the data provided from Github and send it to Keen IO.



Requirements
----
* A [Keen IO](https://keen.io/) account
* An [APItools](https://www.apitools.com/) account



How to use it
----

1. Set up a new monitor and point it to Keen IO (`https://api.keen.io/v3/`)
2. Go to the 'Pipeline' tab in your APITools monitor and add enable this middleware
3. Edit the middleware and substitute `YOUR-WRITE-KEEN-IO-TOKEN-HERE` with your write token from Keen IO
4. Go to your repo on Github and click on Settings >> Webhooks & Services >> Add webhook
![Add webhook screenshot](http://i.imgur.com/36JDgE9.png)
5. Configure the webhook
    * Add your APItools URL followed by the Keen IO project that you want to use. E.g `https://APItools_MONITOR_URL.my.apitools.com/projects/KEEN_IO_PROJECT_ID` **NOTE** Notice that you don't have to put v3 here but in the monitor
    * Select the events that you want to send. E.g `Send me everything.`
7. If everything went well, you should see all the new events from your repo in your project on Keen IO
    * The first event after you set up your webhook is a `ping` event