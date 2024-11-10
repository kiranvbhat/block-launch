@import {"gplayer.ck", "keyboard.ck", "mouse.ck"};

public class RayCaster
{
    GPlayer @ player;

    // Note: assumes points are provided in an order such that edges between the points do not intersect
    fun RayCaster(GPlayer @ gp)
    {
        gp @=> player;
    }

    // returns true if player is inside pad's bounding points AND player is at the same height as the pad
    fun int under_player(GGen pad, float rot_y)
    {
        // check if player is at the same height as the pad (might not be exact)
        0.3 => float height_error;
        if (player.posWorld().y < pad.posWorld().y - height_error) return false;
        if (player.posWorld().y > pad.posWorld().y + height_error) return false;
        
        

        // check if player is within the pad's bounding points
        get_bounding_points(pad, rot_y) @=> vec2 bounding_points[];
        @(player.posWorld().x, player.posWorld().z) => vec2 player_pos;
        point_in_bounds(player_pos, bounding_points) => int pad_is_under_player;
        return pad_is_under_player;
    }

    // returns true if center point of our vision is inside the pad's bounding points (within a constrained distance)
    //
    //      - rot_y: the GPad's rotY
    //      - max_distance: maximum distance of intersection point from our camera
    // Note: we can't accept a GPad as an argument, since that causes an import cycle  (because gpad.ck imports this file)
    fun int in_vision_center(GCube pad, float rot_y, float max_distance)
    {
        // 1. get the bounding points given the pad (assumes pad has no rotation, ignores y-dimension)
        get_bounding_points(pad, rot_y) @=> vec2 bounding_points[];

        // 2. find where the ray (shot directly forward out of player's eye) intersects the pad's xz plane
        player.eye.posWorld().y - pad.posWorld().y => float y_offset;    // the height gap between the camera and the pad
        y_offset / Math.tan(player.eye.rotX()) => float l;               // the horizontal distance to the intersection point

        l * Math.sin(player.rot_y) => float x_offset;
        l * Math.cos(player.rot_y) => float z_offset;

        @(x_offset, y_offset, z_offset) => vec3 offset;
        player.eye.posWorld() + offset => vec3 intersection;

        // 3. if the intersection point is beyond the specified range, then the pad is not in our vision
        if (offset.magnitude() > max_distance) return false;
        
        // 4. use ray-casting algorithm to see if that intersection point is within the bounding points of the pad
        @(intersection.x, intersection.z) => vec2 intersection_2d;       // remove y component for checking bounds
        return point_in_bounds(intersection_2d, bounding_points);
    }

    
    
    // find bounding points of given GGen (assume square shape on xz plane)
    fun vec2[] get_bounding_points(GGen pad, float rot_y)
    {
        // vec2 bounding_points[4];

        // 1. get bounding points as if the pad has no rotation
        vec2 unrotated_bounding_points[4];

        @(pad.posWorld().x, pad.posWorld().z) => vec2 pad_pos;      // don't use y component
        @(pad.scaWorld().x, pad.scaWorld().z) => vec2 pad_scale;    // get dimensions

        pad_pos + @(pad_scale.x/2, pad_scale.y/2) => unrotated_bounding_points[0];
        pad_pos + @(-pad_scale.x/2, pad_scale.y/2) => unrotated_bounding_points[1];
        pad_pos + @(-pad_scale.x/2, -pad_scale.y/2) => unrotated_bounding_points[2];
        pad_pos + @(pad_scale.x/2, -pad_scale.y/2) => unrotated_bounding_points[3];

        // 2. rotate the bounding points (by rot_y radians) around an axis of the pads world position
        // for (int i; i < 4; i++) {
        //     
        //     unrotated_bounding_points - 
        // }
        // pad.rotY()

        return unrotated_bounding_points;           // if I have time i'll fix this by rotating the points first
    }


    // check if a point is in bounds using the ray-casting algorithm
    fun int point_in_bounds(vec2 point, vec2 bounding_points[])
    {
        0 => int num_intersections;
        bounding_points.size() => int num_points;
        for (int i; i < num_points; i++)
        {
            // 1. define edge between bounding point i and bounding point (i+1)%num_points
            bounding_points[i].x => float x1;
            bounding_points[i].y => float y1;
            bounding_points[(i+1)%num_points].x => float x2;
            bounding_points[(i+1)%num_points].y => float y2;

            // 2. check if ray intersects edges vertical range
            if ((Math.min(y1, y2) <= point.y) && (Math.max(y1, y2) >= point.y))
            {
                // 3. if so, find the intersection point
                x1 + ((point.y - y1) * (x2 - x1))/(y2 - y1) => float x_intersect;

                // 4. and check if the intersection point is to the right of our point
                if (x_intersect > point.x) num_intersections + 1 => num_intersections;
            }
        }
        return (num_intersections % 2 == 1);    // true if odd, false if even (or 0)
    }

    // // computes the euclidean distance between point a and point b
    // fun float euclidean_distance(vec3 a, vec3 b)
    // {
    //     a - b => vec3 diff;
    //     return Math.pow(Math.pow(diff.x, 2) + Math.pow(diff.y, 2) + Math.pow(diff.z, 2), 0.5);
    // }
}

Keyboard k();
Mouse m();
spork ~ k.self_update();
spork ~ m.self_update();
GPlayer gp(k, m) --> GG.scene();

RayCaster rc(gp);

@(0, 4, 0) => gp.pos;
// gp.eye.rotX(Math.PI/1.3);       // try negative pi too

GCube pad --> GG.scene();
0.2 => pad.scaY;
// 3 => pad.sca;

// GWindow.fullscreen();

while (true) {
    GG.nextFrame() => now;
    // <<< "in vision center?", rc.in_vision_center(pad, 0, 12) >>>;
    if (rc.in_vision_center(pad, 0, 12)) {
        pad.color(Color.GREEN);
    }
    else {
        pad.color(Color.WHITE);
    }
    // gp.eye.rotateX(-0.01);
}



