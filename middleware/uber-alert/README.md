# Uber price alert

## How to use it

1. Define Uber API endpoint as you APItools service URL `https://api.uber.com/v1/`
2. Add Uber-passinfo middleware before in the pipeline
3. In PriceAlert middleware, change `max_price` to your desired price and `my_address` to with email address
4. Make call to http://YOUROWN.apitools.com/estimates/price to receive an email when uber price is above your limit