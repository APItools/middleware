# BurningMan Demultiply middleware

# Why

The original endpoint returns event with an *occurrence_set* array containing all the dates the event is happening.

This middleware creates single event for each occurent of an event.

## How to use it

1. Define Burningman API endpoint as you APItools service URL `http://playaevents.burningman.com/api/0.2/{year}/`
2. Make call to http://YOUROWN.apitools.com/event