# Description:
#   Enhance an image
#
# Dependencies:
#   gm
#   request
#
# Configuration:
#   HUBOT_IMGUR_CLIENT_ID (Required)
#   HUBOT_SLACK_TOKEN (Optional)
#
# Commands:
#   hubot enhance
#
# Author:
#   Evan Coleman (edc1591)

enhanceDelay = 1000

gm = require('gm')
request = require('request');

module.exports = (robot) ->
  robot.respond /enhance$/i, (msg) ->
    fetchLatestImage msg, (url, w, h) ->
      if url != null
        processImage url, w, h, 50, 50, (url) ->
          msg.send url

  robot.respond /enhance [0-9][0-9]?[0-9]? [0-9][0-9]?[0-9]?(.*)?/i, (msg) ->
    split = msg.match.input.split(" ")
    x = split[2]
    y = split[3]
    if split.length > 4
      input = split[4].replace(">", "").replace("<", "")
      getDimensions input, (width, height) ->
        enhance msg, input, width, height, x, y
    else
      fetchLatestImage msg, (url, width, height) ->
        enhance msg, url, width, height, x, y

getDimensions = (url, cb) ->
  gm(request(url), "image.jpg")
    .options({imageMagick: true})
    .size (err, size) ->
      cb size.width, size.height

enhance = (msg, url, w, h, x, y) ->
  processImage url, w, h, x, y, (url) ->
    msg.send url
    setTimeout ( ->
      processImage url, w, h, 50, 50, (url) ->
        msg.send url
        setTimeout ( ->
          processImage url, w, h, 50, 50, (url) ->
            msg.send url
            setTimeout ( ->
              processImage url, w, h, 50, 50, (url) ->
                msg.send url
            ), enhanceDelay
        ), enhanceDelay
    ), enhanceDelay

fetchLatestImage = (msg, cb) ->
  if msg.robot.adapterName == "slack"
    request.get "https://slack.com/api/channels.list?token="+process.env.HUBOT_SLACK_TOKEN, (err, resp, body) ->
      channelsResp = JSON.parse body
      channelId = item.id for item in channelsResp.channels when item.name == msg.message.room
      request.get "https://slack.com/api/channels.history?token="+process.env.HUBOT_SLACK_TOKEN+"&channel="+channelId, (err, resp, body) ->
        history = JSON.parse body
        attachment = null
        for item in history.messages
          if item.attachments and item.attachments.length > 0 and item.attachments[0].image_url
            attachment = item.attachments[0]
            break
        if attachment == null
          msg.reply "Couldn't find any images."
          return
        cb attachment.image_url, attachment.image_width, attachment.image_height
  else
    msg.reply "You must specify an image URL."
    cb null, 0, 0

processImage = (url, w, h, x, y, cb) ->
  if url != null
    console.log "Enhancing " + url
    width = w / 2
    height = h / 2
    console.log "Width: " + width + ", Height: " + height + ", x:" + ((width * (x / 100))) + ", y:" + ((height * (y / 100)))
    gm(request(url), "image.jpg")
      .options({imageMagick: true})
      .crop(width, height, (width * (x / 100)), (height * (y / 100)))
      .resize(w, h)
      .stream (err, stdout, stderr) ->
        buf = new Buffer(0)
        stdout.on 'data', (d) ->
          buf = Buffer.concat([buf, d])
        stdout.on 'end', () ->
          options =
            url: "https://api.imgur.com/3/image"
            formData:
              image: buf
            headers:
              "Authorization": "Client-ID " + process.env.HUBOT_IMGUR_CLIENT_ID
          request.post options, (err, httpResponse, body) ->
            cb JSON.parse(body).data.link