# Yo API middlware

## How to use it

1. Define Yo API endpoint as you APItools service URL `http://api.justyo.co/`
2. Define the Yo URL callback with your APItools URL `http://token.APITOOLS.com`
3. Add CORS-header middleware in the pipeline
4. Change `YO_API_TOKEN` in `yo.lua` by your own Yo API key.
5. Call `http://token.APITOOLS.com/yo` in your app to send individual Yos

## Tutorial
More descriptive tutorial can be found [here](https://docs.apitools.com/2014/07/15/develop-your-first-yo-app-with-apitools.html)