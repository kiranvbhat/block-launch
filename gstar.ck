public class GStar extends GGen
{
    5 => int NUM_SHAPES;
    GGen @ star;
    0.5 => float STAR_SCALE;
    
    Math.PI/4 => float MAX_ROT_SPEED;
    // 0.04 => float MAX_ROT_SPEED;   // 0.04
    vec3 rotate_amount;
    false => int rotation_on;

    fun GStar()
    {
        // choose_random_shape();
        make_sphere();
        set_random_rotation();
    }

    fun void make_sphere()
    {
        new GSphere() @=> star;
        star.sca(STAR_SCALE);
        star --> this;
    }
    
    fun void choose_random_shape()
    {
        Math.random2(0, NUM_SHAPES-1) => int shape;

        if (shape == 0) new GSphere() @=> star;
        else if (shape == 1) new GCube() @=> star;
        else if (shape == 2) new GTorus() @=> star;
        else if (shape == 3) new GCylinder() @=> star;
        else if (shape == 4) new GSuzanne() @=> star;

        star.sca(0.5);
        star --> this;
        // star.color(Color.WHITE);
    }

    fun void set_random_rotation()
    {
        @(Math.random2f(-MAX_ROT_SPEED, MAX_ROT_SPEED), Math.random2f(-MAX_ROT_SPEED, MAX_ROT_SPEED), Math.random2f(-MAX_ROT_SPEED, MAX_ROT_SPEED)) => rotate_amount;
        this.rotate(rotate_amount);
    }



    fun void update(float dt)
    {
        if (rotation_on) this.rotate(rotate_amount);
    }
}