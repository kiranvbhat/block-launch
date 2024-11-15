public class GPlanet extends GGen
{
    Constants c;
    GGen @ planet;
    c.PLANET_ROTATE_AMOUNT => float rotate_amount;

    fun GPlanet()
    {
        load_planet();
    }

    fun void load_planet()
    {
        AssLoader ass_loader;
        ass_loader.loadObj(me.dir() + "models/earth.obj") @=> planet;
        planet.sca(c.PLANET_SCALE);
        planet --> this;
    }

    fun void update_rotation_speed(float tempo)     // use tempo of music to update the planet's rotation speed
    {
        (tempo / c.DEFAULT_TEMPO) => float tempo_ratio;
        Math.pow(tempo_ratio, c.PLANET_ROTATION_EXP) * c.PLANET_ROTATE_AMOUNT => rotate_amount;
        // <<< "updated planet rotation amount to:", rotate_amount >>>;
    }

    fun void update(float dt)
    {
        this.rotateOnWorldAxis(c.PLANET_ROTATION_AXIS, rotate_amount);
    }
}