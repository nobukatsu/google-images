request = require 'request'
fs = require 'fs'

generateInfo = (item) ->
  info = 
		height: item.image.height
		width: item.image.width
		url: item.link
		byteSize: item.image.byteSize
		thumbnailLink: item.image.thumbnailLink
		thumbnailHeight: item.image.thumbnailHeight
		thumbnailWidth: item.image.thumbnailWidth
		writeTo: (path, callback) ->
			stream = fs.createWriteStream path
			stream.on 'close', ->
				callback?()
			request(item.url).pipe stream
  return info

exports.search = (query, options) ->

	requestUrl = "https://www.googleapis.com/customsearch/v1?q=#{ encodeURIComponent(query.replace(/\s/g, '+')) }&searchType=image&cx=#{ options.cse_id }&key=#{ options.cse_api_key }"

	# Because CSE API does not allow size and page parameters to be undefined
	# Only apply them if they are defined
	if options.page
		requestUrl = requestUrl + "&start=#{ options.page }"

	if options.size
		requestUrl = requestUrl + "&imgSize=#{ options.size }"

	if typeof query is 'object'
		options = query
		query = options.for
		callback = options.callback if options.callback?
	if typeof query is 'string' and typeof options is 'function'
		callback = options
		options = {}
	if typeof query is 'string' and typeof options is 'object'
		callback = options.callback if options.callback?
	
	request requestUrl, (err, res, body) ->
		try
			data = JSON.parse(body)
		catch error
			callback no, [] if callback
			return

		if not data.items
			callback no, [] if callback
			return

		items = data.items

		images = []
		for item in items
      images.push generateInfo item
		
		callback no, images if callback