public class GStar extends GGen
{
    GTorus star --> this;
    star.sca(1.5);
    star.color(Color.WHITE);

    0.04 => float MAX_ROT_SPEED;
    // Math.random2(0, 1) => int star_rotates;
    @(Math.random2f(-MAX_ROT_SPEED, MAX_ROT_SPEED), Math.random2f(-MAX_ROT_SPEED, MAX_ROT_SPEED), Math.random2f(-MAX_ROT_SPEED, MAX_ROT_SPEED)) => vec3 rotate_amount;

    // fun void choose_random_shape()
    // {

    // }

    fun void update(float dt)
    {
        this.rotate(rotate_amount);
    }
}