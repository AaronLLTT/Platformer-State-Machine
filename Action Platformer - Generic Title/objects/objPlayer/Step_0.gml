/// @description Movement & Controls

var left = keyboard_check(ord("A"));
var leftReleased = keyboard_check_released(ord("A"));
var right = keyboard_check(ord("D"));
var rightReleased = keyboard_check_released(ord("D"));
var jump = keyboard_check_pressed(vk_space);
var roll = keyboard_check_pressed(vk_lshift);
var rangedAttack = mouse_check_button_pressed(mb_left);
var meleeAttack = mouse_check_button_pressed(mb_right);
var slide = mouse_check_button_pressed(mb_middle);

var onGround = place_meeting(x, y + 1, objBlock);

#region Idle
    if currentState == State.Idle {
    	//Change to running
    	if left || right {
    		ChangeState(State.Running, sprArcherRun);
    	}
    	//Change to jumping
    	else if jump {
    		ChangeState(State.StartJump, sprArcherStartJump);
    	}
    	//Roll
    	else if roll {
    		ChangeState(State.Rolling, sprArcherRoll);
    		ySpeed = rollHeight;
    	}
    	//Falling
    	else if ySpeed != 0
    		ChangeState(State.Falling, sprArcherFalling);
    	
    	//Ranged attack
    	else if rangedAttack {
    		ChangeState(State.RangedAttack, sprArcherRangedAttack);
    	}
        //Melee Attack
        else if meleeAttack {
            ChangeState(State.MeleeAttack, sprArcherMeleeAttack);
        }
    	
    	//Check gravity because of sitauations like rolling off blocks
    	CheckOnGround();
    	y += ySpeed;
    }
#endregion

#region Start Jump

    else if (currentState == State.StartJump) {
    	var frame = image_index;
    	xSpeed = 0;
    	
    	if (frame + image_speed) >= image_number {
    		currentState = State.MovingUp;
    		image_index = 0;
    		sprite_index = sprArcherMoveUp;
    		ySpeed = jumpSpeed;
    	}
    	
    	//Able to start moving left and right
    	MoveLeftAndRight()
    	x += xSpeed;
    }

#endregion

#region Moving Up

    else if (currentState == State.MovingUp) {
    	//Transition to falling
    	if ySpeed > 0 {
    		currentState = State.Falling;
    		sprite_index = sprArcherFalling;
    		image_index = 0;
    	}
        //Check for vertical collisions
        if place_meeting(x, y + ySpeed, objBlock) {
            ySpeed = 1;
            sprite_index = sprArcherFalling;
            image_index = 0;
        }
        //Check for ranged air attack
        if rangedAttack {
            ChangeState(State.AirRangedAttack, sprArcherAirAttack);
        }
    	
    	//Move
    	ySpeed += gameGravity;
    	SetTerminalVelocity()
    	y += ySpeed;
    	
    	//Control horizontal movement
    	MoveLeftAndRight()
    	x += xSpeed;
    }

#endregion

#region Falling

    else if (currentState == State.Falling) {
    	
    	ySpeed += gameGravity;
    	
        //Check for landing
    	if place_meeting(x, y + ySpeed, objBlock) {
    		currentState = State.Landing;
    		sprite_index = sprArcherLand;
    		image_index = 0;
    		ySpeed = 0;
    	}
        //Check for ranged air attack
        if rangedAttack {
            ChangeState(State.AirRangedAttack, sprArcherAirAttack);
        }
    	
    	SetTerminalVelocity();
    	y += ySpeed;
    	
    	//Left and Right
    	MoveLeftAndRight()
    	x += xSpeed;
    }
#endregion

#region Landing

    else if (currentState == State.Landing) {
    
    	while(!place_meeting(x, y + 1, objBlock)) {
    		y += 1;
    	}
    	
    	if (image_index + image_speed) >= image_number {
    		currentState = State.Idle;
    		image_index = 0;
    		sprite_index = sprArcherIdle;
    	}
    	
    	//Switch back to jumping
    	if jump {
    		currentState = State.StartJump;
    		sprite_index = sprArcherStartJump;
    		image_index = 0;
    	}
    	
    	MoveLeftAndRight();
    	x += xSpeed;
    }

#endregion

#region Running

    else if currentState == State.Running {
    	if left {
    		image_xscale = -1;
    		xSpeed = -runSpeed;
    	}
    	else if right {
    		image_xscale = 1;
    		xSpeed = runSpeed;
    	}
    	//Change to idle state
    	if leftReleased || rightReleased {
    		ChangeState(State.Idle, sprArcherIdle);
    	}
    	
    	//Change to jumping state
    	else if jump {
    		ChangeState(State.StartJump, sprArcherStartJump);
    	}
    	
    	else if (ySpeed > 0) {
    		ChangeState(State.Falling, sprArcherFalling);
    	}
    	
    	//Rolling
    	else if roll {
    		ChangeState(State.Rolling, sprArcherRoll);
    		ySpeed = rollHeight;
    	}
    	
    	//Ranged Attack
    	else if rangedAttack {
    		ChangeState(State.RangedAttack, sprArcherRangedAttack);
    	}
        
        //Melee Attack
        else if meleeAttack {
            ChangeState(State.MeleeAttack, sprArcherMeleeAttack);
        }
        
        //Sliding
        else if slide {
            ChangeState(State.Sliding, sprArcherSlide);
            xSpeed *= 2;
        }
    	
    	//Check if running off ground
    	CheckOnGround();
    	
    	//Move
    	MoveLeftAndRight();
    	x += xSpeed;
    }

#endregion

#region Rolling
    else if currentState == State.Rolling {
    	//Return to default stated
    	if AnimationOver() {
    		if left || right
    			ChangeState(State.Running, sprArcherRun);
    		else
    			ChangeState(State.Idle, sprArcherIdle);
    	}
    	
    	if place_meeting(x, y + ySpeed, objBlock) {
    		while(!place_meeting(x, y + sign(ySpeed), objBlock)) {
    			y += sign(ySpeed);
    		}
    		ySpeed = 0;
    	}
    	
    	//Move
    	xSpeed = rollSpeed * image_xscale;
    	XCollisions();
    	x += xSpeed;
    	
    	CheckOnGround();
    	y += ySpeed;
    }

#endregion

#region Ranged Basic Attack

    else if currentState == State.RangedAttack {
    	if AnimationOver() {
    		ChangeState(State.Idle, sprArcherIdle);
    	}
    	
    	//Create arrow at specific frame
    	if (image_index + 0.5) > 7 && (image_index - 0.5) < 8 {
    		var dir;
    		if image_xscale == -1
    			dir = 180;
    		else
    			dir = 0;
    		instance_create_depth(bbox_left, bbox_top + 10, depth - 1, objArcherArrow, {
    			speed : 20,
    			direction : dir
    		});
    		image_index += 1.5; //Increase the index manually to avoid creating multiple arrows
    	}
    }

#endregion

#region Basic Melee Attack

    else if currentState == State.MeleeAttack {
        if AnimationOver() {
            ChangeState(State.Idle, sprArcherIdle);
        }
    }

#endregion

#region Air Ranged Attack

    else if currentState == State.AirRangedAttack {
        if AnimationOver() {
            ReturnToPreviousState();
        }

        //Create arrow at specific frame
    	if (image_index + 0.5) > 4 && (image_index - 0.5) < 5 {
    		var dir;
    		if image_xscale == -1 {
    			dir = 230;
                instance_create_depth(bbox_left, bbox_top + 20, depth - 1, objArcherArrow, {
        			speed : 20,
        			direction : dir,
                    image_angle : dir
        		});
            }
    		else {
    			dir = 320;
                instance_create_depth(bbox_left, bbox_top - 20, depth - 1, objArcherArrow, {
        			speed : 20,
        			direction : dir,
                    image_angle : dir
        		});
            }
    		
    		image_index += 1.5;
    	}
    }

#endregion

#region Sliding

    else if currentState == State.Sliding {
        //Return to idle or running
        if AnimationOver() {
            if left || right
                ReturnToPreviousState();
            else {
                ChangeState(State.Idle, sprArcherIdle);
            }
        }
        
        //Move / Slide across the ground
        x += xSpeed;
        XCollisions();
        CheckOnGround();
        y += ySpeed;
    }

#endregion