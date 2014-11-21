# Send of HTTP(s) responses' size to Keen IO

## Overview

Keen IO allows you to gather data from different places and consume it in a very easy way using their APIs. This middleware send data from APItools - in this case the sizes of the HTTP(s) responses - to Keen IO. Any metric could be sent just changing the #response.body parameter.

## How to use it

1. Set up any API service that you want to monitor, e.g. `https://api.500px.com/v1/`
2. Make sure you're hitting the API and the requests are being logged on APItools. To achieve that check the 'Integration' tab, make a call (from your app or using cURL), and then go back to the 'Traces' tab to verify it went through.
3. Go to the 'Pipeline' tab, create new middleware and copy and paste this code.
4. Sign in to your Kenn IO account and get your API KEY and PROJECT ID. If you don't have an account, you can create one for free here https://keen.io/. Once you have your keys, add them to the middleware that you just created. You will also have to pick a name for your 'Event Collection' and change it in your middleware code. Hit Apply and Save.
5. Make a new request.
6. If everything went well, you should see the size of the request in your project on Keen IO.


