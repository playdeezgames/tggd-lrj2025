package game

// The original's twelve sound effects (Sfx.vb). The core queues them; the platform plays the queue after each step.
// (Craft.wav sits in the original's wwwroot but nothing references it, so it is not ported.)

Sfx :: enum u8 {
	Player_Hit,
	Take,
	Eat,
	Woo_Hoo,
	Shucks,
	Yoink,
	Tasty,
	Enemy_Death,
	Enemy_Hit,
	Enemy_Miss,
	Player_Death,
	Player_Miss,
}

SFX_QUEUE_SIZE :: 16

// Paths are relative to the page.
SFX_FILES :: [Sfx]string {
	.Player_Hit   = "sfx/PlayerHit.wav",
	.Take         = "sfx/Take.wav",
	.Eat          = "sfx/Eat.wav",
	.Woo_Hoo      = "sfx/WooHoo.wav",
	.Shucks       = "sfx/Shucks.wav",
	.Yoink        = "sfx/Yoink.wav",
	.Tasty        = "sfx/Tasty.wav",
	.Enemy_Death  = "sfx/EnemyDeath.wav",
	.Enemy_Hit    = "sfx/EnemyHit.wav",
	.Enemy_Miss   = "sfx/EnemyMiss.wav",
	.Player_Death = "sfx/PlayerDeath.wav",
	.Player_Miss  = "sfx/PlayerMiss.wav",
}

// Queues a sound for the platform; dropped when a single step asks for more than the queue holds.
play_sfx :: proc(core: ^Core, sfx: Sfx) {
	if core.sfx_count < SFX_QUEUE_SIZE {
		core.sfx_queue[core.sfx_count] = sfx
		core.sfx_count += 1
	}
}
