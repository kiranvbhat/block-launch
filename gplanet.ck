public class GPlanet extends GGen
{
    // 5 => int NUM_RINGS;
    GGen @ planet;
    // GTorus rings[];
    
    @(0, 1, 0.4) => vec3 rotation_axis;
    0.0005 => float rotate_amount;

    fun GPlanet()
    {
        load_planet();
    }

    fun void load_planet()
    {
        AssLoader ass_loader;
        ass_loader.loadObj(me.dir() + "models/earth.obj") @=> planet;
        // ass_loader.loadObj(me.dir() + "models/rock1.obj") @=> planet;
        planet.sca(200);
        planet --> this;
    }

    fun void update_rotation_speed(float bpm)     // use bpm of music to update the planet's rotation speed
    {
        bpm / 120 => float rotation_rate;
    }

    fun void update(float dt)
    {
        this.rotateOnWorldAxis(rotation_axis, rotate_amount);
    }
}