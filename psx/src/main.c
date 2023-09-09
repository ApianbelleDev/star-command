#include "include/engine.h"
#include "include/obj.h"

int main(int argc, const char **argv) {

	// Initialize the GPU and load the default font texture provided by
	// PSn00bSDK at (960, 0) in VRAM.
	ResetGraph(0);
	FntLoad(960, 0);

	// Set up our rendering context.
	RenderContext ctx;
	setup_context(&ctx, SCREEN_XRES, SCREEN_YRES, 0, 0, 0);

	srand(1);

	//setup structs for game objects
	struct Player turret;
	struct Bullet bullet;
	struct Comet comet;

	turret.x = SCREEN_XRES / 2;
	turret.y = 200;
	turret.w = 32;
	turret.h = 32;
	turret.dx = 0.1;
	turret.dy = 0.1;
	turret.speed = 20;

	bullet.x = OFFSCREEN_X;
	bullet.y = OFFSCREEN_Y;
	bullet.w = 4;
	bullet.h = 4;
	bullet.dy = 0.1;
	bullet.speed = 30;
	bullet.is_shot = false;

	comet.x = SCREEN_XRES / 2;
	comet.y = -80;
	comet.w = 64;
	comet.h = 64;
	comet.dy = 0.1;
	comet.speed = 5;
	comet.is_destroyed = false;

	struct BoundingBox b_bound;
	struct BoundingBox c_bound;

	PADTYPE *pad;

	//initialize gamepads
	InitPAD( padbuff[0], 34, padbuff [1], 34);

	//begin polling
	StartPAD();

	//To avoid VSync Timeout error
	ChangeClearPAD(1);
	while(true){

		int rng_x = (rand() % (280 - 20 + 1)) + 0;

		pad = (PADTYPE*)padbuff[0];

		if(pad->stat == 0){
			if((pad->type == 0x4) || (pad->type == 0x5) || (pad->type == 0x7)){
				if (!(pad->btn&PAD_LEFT)) {
					if(turret.x <= SCREEN_LEFTBOUND){
						turret.dx = 0;
					}
					turret.x -= turret.dx * turret.speed;

				}
				else if (!(pad->btn&PAD_RIGHT)) {
					if(turret.x >= SCREEN_RIGHTBOUND){
						turret.dx = 0;
					}
					turret.x += turret.dx * turret.speed;
				}

				if (!(pad->btn&PAD_CROSS)) {
					bullet.y = turret.y + 16;
					bullet.x = turret.x + 16;
					bullet.is_shot = true;
				} else {
					turret.dx = 0.1;
					bullet.is_shot = false;
				}

			}

		}

		if (bullet.is_shot = true) {
			bullet.y -= bullet.dy * bullet.speed;
		}

		b_bound.x = bullet.x;
		b_bound.y = bullet.y;
		b_bound.w = bullet.w;
		b_bound.h = bullet.h;

		c_bound.x = comet.x;
		c_bound.y = comet.y;
		c_bound.w = comet.w;
		c_bound.h = comet.h;

		if ((b_bound.x + b_bound.w >= c_bound.x) && // left - right
    		(b_bound.x <= c_bound.x + c_bound.w) && // right - left
    		(b_bound.y + c_bound.h >= c_bound.y) && // down - up
    		(b_bound.y <= c_bound.y + c_bound.h)) { // up - down
    		if(bullet.is_shot){
    			comet.x = rng_x;
    			comet.y = -80;
    			bullet.x = OFFSCREEN_X;
    			bullet.y = OFFSCREEN_Y;
    		}
	}
		//constantly move comet down
		comet.y += comet.dy * comet.speed;

		// Draw the primitives by allocating a TILE (i.e. untextured solid color
		// rectangle) primitive at Z = 1.
		SPRT *playerTile = (SPRT *) new_primitive(&ctx, 2, sizeof(SPRT));
		TILE *bulletTile = (TILE *) new_primitive(&ctx, 1, sizeof(TILE));
		TILE *cometTile  = (TILE *) new_primitive(&ctx, 2, sizeof(TILE));


		setSprt(playerTile);
		setXY0 (playerTile, turret.x, turret.y);
		setWH  (playerTile, turret.w, turret.h);
		setUV0 (playerTile, turret_uoffs, turret_voffs);
		setClut(playerTile, turret_crect.x, turret_crect.y);
		setRGB0(playerTile, 255, 255, 255);

		setTile(bulletTile);
		setXY0 (bulletTile, bullet.x, bullet.y);
		setWH  (bulletTile, bullet.w, bullet.h);
		setRGB0(bulletTile, 255, 255, 255);

		setTile(cometTile);
		setXY0 (cometTile, comet.x, comet.y);
		setWH  (cometTile, comet.w, comet.h);
		setRGB0(cometTile, 255, 255, 255);

		flip_buffers(&ctx);

	}

	return 0;
}
