#include <stdbool.h>

struct System {
	bool is_running;
	int game_state;
};


struct Player{
	double x;
	double y;
	double dx;
	double dy;
	int speed;
	int w;
	int h;
};

struct Bullet {
	double x;
	double y;
	double w;
	double h;
	double dy;
	int speed;
	bool is_shot;
};

struct Comet {
	int x;
	double y;
	double w;
	double h;
	double dy;
	int speed;
	bool is_destroyed;
};

struct BoundingBox {
	double w;
	double h;
	double x;
	double y;
};