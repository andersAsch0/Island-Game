extends AnimatedSprite2D



func playClosingAnim(backward : bool = false):
	$openAndCloseFX.play(0.0)
	play("default")

