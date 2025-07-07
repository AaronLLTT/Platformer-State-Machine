/// @description Essential Data

xSpeed = 0;
ySpeed = 0;

runSpeed = 3.5;
rollSpeed = 5;
rollHeight = -4.2;
jumpSpeed = -8;
gameGravity = 0.3;
maxFallSpeed = 10;

image_speed = 0.5;

enum State {
	Idle,
	Running,
	StartJump,
	MovingUp,
	Falling,
	Landing,
	Rolling,
	Hit,
	RangedAttack,
	MeleeAttack,
    AirRangedAttack,
    Sliding
}

currentState = State.Idle;
previousState = State.Idle;
previousSprite = sprArcherIdle;
previousImageIndex = 0;

/// @function ChangeState(newState, newSprite)
/// @param {Enum.State} newState The state to change into
/// @param {Asset.GMSprite} newSprite The new sprite
ChangeState = function(newState, newSprite) {
    previousState = currentState;
    previousSprite = sprite_index;
    previousImageIndex = image_index;
	currentState = newState;
	sprite_index = newSprite;
	image_index = 0;
}

/// @function ReturnToPreviousState
/// Return to the last state and change the sprite
ReturnToPreviousState = function() {
    currentState = previousState;
    sprite_index = previousSprite;
    image_index = previousImageIndex;
}

/// @function Determine if the player is on the ground and 
/// apply gravity and max fall speed if they're not
CheckOnGround = function() {
	var onGround = place_meeting(x, y + 1, objBlock);
	
	if !onGround {
		ySpeed += gameGravity;
	}
	
	SetTerminalVelocity();
}

XCollisions = function() {
	if place_meeting(x + xSpeed, y, objBlock) {
		while(!place_meeting(x + sign(xSpeed), y, objBlock)) {
			x += sign(xSpeed);
		}
		xSpeed = 0;
	}
}

AnimationOver = function() {
	var frame = image_index;
	
	if (frame + image_speed) > image_number {
		return true;
	}
	
	return false;
}

SetTerminalVelocity = function() {
	//Set max falling speed
	ySpeed = clamp(ySpeed, jumpSpeed, maxFallSpeed);	
}

MoveLeftAndRight = function() {
	var left = keyboard_check(ord("A"));
	var right = keyboard_check(ord("D"));
	var leftReleased = keyboard_check_released(ord("A"));
	var rightReleased = keyboard_check_released(ord("D"));
	
	if left {
		xSpeed = -runSpeed;
		image_xscale = -1;
	}
	if right {
		xSpeed = runSpeed;
		image_xscale = 1;
	}
	
	if leftReleased || rightReleased {
		xSpeed = 0;
	}
	
	XCollisions();
}