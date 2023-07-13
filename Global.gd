#this is a global script (created via project settings > autoload)
#it is always running, and thus this variable is always accessible to other scripts
#STORES GLOBALLY NEEDED VARIABLES

extends Node

var door_name = null

var overWorldLocation = Vector2(62, 43) #stored location for use when loading back into overworld
var enemyName = "" #name of enemy most recently fought 
var overWorldShouldDespawnEnemy = false #when loading into the overworld, this is used to know if it should despawn an enemy
