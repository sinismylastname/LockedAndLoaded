extends Node

var enemyCount = 0

signal enemy_count_changed(newCount)

func increaseEnemyCount():
	enemyCount += 1
	enemy_count_changed.emit(enemyCount)

func decrease_enemy_count():
	enemyCount -= 1
	enemy_count_changed.emit(enemyCount)
