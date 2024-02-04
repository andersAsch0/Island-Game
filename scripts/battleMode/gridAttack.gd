extends Node2D


@onready var gridSquareNodes = [[$grid00, $grid01, $grid02],[$grid10, $grid11, $grid12],[$grid20, $grid21, $grid22]]

func attack(x, y, warningTime):
	gridSquareNodes[x][y].attack(warningTime)
