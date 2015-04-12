# hubot-enhance

A hubot script for "enhancing" images

See [`src/enhance.coffee`](src/enhance.coffee) for more documentation.

## Installation

In hubot project repo, run:

`npm install hubot-enhance --save`

Then add **hubot-enhance** to your `external-scripts.json`:

```json
[
  "hubot-enhance"
]
```

## Configuration

`HUBOT_IMGUR_CLIENT_ID`: *Required*. The client ID of your Imgur app. Used to upload enhanced images.
`HUBOT_SLACK_TOKEN`: *Optional*. Used to query chat history to get the last posted image.

## Example Interactions

`user> hubot enhance`: Enhances the last posted image once using a box half the width and height of the original centered at the center of the image.
`user> hubot enhance 25 50`: Enhances the last posted image four times using a box hald the width and height of the original centered at a point 25% in from the left and 50% down from the top.
`user> hubot enhance 25 50 http://some.image.com/image.jpg`: Does the same thing as the above command but uses the specified image instead.