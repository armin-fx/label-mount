
diameter = 6;
wall     = 2;
gap      = 0.1;
depth    = 10;

bevel_angle = 45;

/* [Hidden] */

include <banded.scad>
include <../helper.scad>

$fd = $preview ? 0.02 : 0.005;
diameter_outer = diameter + 2*wall;

for (i=[0:9])
{
	clips_snap_width = i * 0.1;
	
	//angle = 2 * aexcsc (gap / (diameter/2));
	angle = achord ( (diameter - clips_snap_width) / (diameter/2+gap));

	echo(i, angle);
	
	translate_y(i * (diameter+wall*2 + 1))
	difference()
	{
		translate_z (diameter_outer/2)
		rotate_y    (90)
		rotate_z    (-bevel_angle) // <--
		union()
		{
			mirror_copy(X-Y) // <--
			translate_x (diameter_outer/2)
			translate_y (tan(bevel_angle/2) * diameter_outer/2)
			union()
			{
				edge_rounded (h=depth, d=diameter_outer, extra=0, $fn=1
					, angle=configure_angle( opening=180-bevel_angle, end=-90)
					);
				edge_rounded (h=depth, d=diameter_outer, extra=-0.1, $fn=1
					, angle=configure_angle( opening=180-bevel_angle, end=-90)
					);
			}

			ring_square (h=depth
				, di=diameter+2*gap
				, do=diameter+2*wall
				, angle= [360-angle, -45]
				);
		}
		//
	//	translate_x(2) mirror_x() rotate_z(90)
		translate_x(2) translate_y(-1.75) mirror_x() rotate_z(90)
		translate_z(-extra) linear_extrude(0.5+extra)
		scale(0.27)
		text(str(i), font=":bold");
	}
}


