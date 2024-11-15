public class PhysicsObject
{
    60.0 => float FPS;
    
    // properties of world/object set by user
    vec3 gravity;
    float mass;
    float mu_k;            // kinetic friction coefficient
    float fluid_density;
    float c_d;             // drag coefficient
    float surface_area;

    // flags
    true => int normal_force_on;

    // current state of physics object!!! This is what we need to keep updated!
    vec3 acceleration;
    vec3 velocity;
    vec3 position;

    vec3 external_force;
    

    // ------------------- constructor -------------------
    // -  m: mass
    // -  g: gravity acceleration constant
    // -  f: kinetic friction coefficient
    // -  p: fluid density (of fluid surrounding object)
    // - cd: drag coefficient
    // -  a: surface area
    fun PhysicsObject(float m, float g, float f, float p, float cd, float a)
    {
        m => mass;
        @(0, -g, 0) => gravity;
        f => mu_k;                  // kinetic friction coefficient
        p => fluid_density;
        cd => c_d;                  // drag coefficient
        a => surface_area;
    }
    // -----------------------------------------------------
    
    

    // ------------------------- computing position/velocity/acceleration -------------------------

    // should be called every frame, to update the position of the physics object
    fun void update_position(float dt)
    {
        // dt => timestep;

        // 1. update the current acceleration of the physics object, based on active forces
        update_acceleration(dt);
        
        // 2. compute the velocity with the current acceleration
        update_velocity(dt);

        // 3. compute the new position with the updated velocity
        position + (velocity * dt) => position;
    }


    fun void update_velocity(float dt)
    {
        velocity + (acceleration * dt) => velocity;
    }


    fun void update_acceleration(float dt)
    {

        vec3 total_force;
        if (normal_force_on)
        {
            get_normal_force() => vec3 normal_force;
            total_force + normal_force => total_force;
            total_force + get_friction_force(normal_force) => total_force;     // 0.4 is kinetic friction coefficient
        }
        total_force + get_gravity_force() => total_force;
        total_force + get_drag_force() => total_force;
        total_force + get_external_force() => total_force;

        // scale the y-force based on the timestep (so launching/jumping is consistent across different framerates)
        if (dt > 0) total_force.y / (dt * FPS) => total_force.y;

        // <<< "total force for acceleration:", total_force >>>;

        // 2. set acceleration based on all current forces
        total_force / mass => acceleration;
    }

    // ------------------------- force calculation functions -------------------------
    fun vec3 get_normal_force()
    {
        return -1 * get_gravity_force();
    }

    fun vec3 get_friction_force(vec3 normal_force)
    {
        // 1. magnitude of normal force * negative normalized velocity = unnormalized friction force
        velocity => vec3 normalized_velocity;
        normalized_velocity.normalize();
        normal_force.magnitude() * (-1 * normalized_velocity) => vec3 friction_force;

        // 2. normalize with kinetic friction coefficient
        mu_k * friction_force => friction_force;
        return friction_force;
    }

    fun vec3 get_gravity_force()
    {
        return gravity * mass;
    }

    fun vec3 get_drag_force()   // air resistance
    {
        Math.pow(velocity.magnitude(), 2) * velocity => vec3 square_velocity;
        0.5 * fluid_density * (-1 * square_velocity) * c_d * surface_area => vec3 drag_force;
        return drag_force;
    }

    fun vec3 get_external_force()
    {
        return external_force;
    }
    // ------------------------------------------------------------------------------


    // ------------- functions to manipulate movement of physics object -------------
    // unrealistic physics in order to immediately stop player's vertical movement when they hit the ground
    fun void contact_ground()
    {
        <<< "contacted ground!!" >>>;
        true => normal_force_on;
        @(velocity.x, 0, velocity.z) => velocity;
    }

    fun void leave_ground()
    {
        false => normal_force_on;
    }

    fun void set_external_force(vec3 force)
    {
        force => external_force;
    }

    fun void apply_external_force(vec3 force)
    {
        external_force + force => external_force;
    }

    fun void set_gravity(float g)
    {
        @(0, -g, 0) => gravity;
    }
}