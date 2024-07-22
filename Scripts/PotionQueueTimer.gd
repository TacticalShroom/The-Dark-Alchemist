extends Timer



var bottle

func queue(bottleToQueue):
	self.start()
	bottle = bottleToQueue



func timeout():
	bottle.queue_free()
