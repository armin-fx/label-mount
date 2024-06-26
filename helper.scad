include <banded.scad>

required_version ([3,0,0]);

// - Projektspezifische Module:

//                     (wall, snap_depth)
module snap_silhouette (height, width)
{
	render()
	difference()
	{
		square ([width, height]);
		//
		triangle (width, side=1);
		//
		translate_y (height-width)
		triangle (width, side=2);
	}
}

//                      (wall, wall_side, 5)
module tooth_silhouette (height, depth, width=5, angle=30)
{
	width_top = width + 2*tan(angle)*depth;
	
	linear_extrude (height)
	polygon(
		[[ 0    ,  width/2]
		,[-depth,  width_top/2]
		,[-depth, -width_top/2]
		,[ 0    , -width/2]
	] );
}

// Put the connection line along the x axis
// where the negative y side is the tooth part
// and the positive y side the plate part.
// Must use in block with 'combine()'
//
//                (length, wall, wall_side, snap_depth, gap, ???)
module connection (length, height, depth, snap_depth, gap=0, height_extra=0)
{
	snap_distance =  3;
	snap_length   = 10;
	tooth_length  =  5;
	//
	count = ceil( (length-2*snap_distance-tooth_length) / (snap_length+tooth_length+snap_distance*2) );
	//echo ("connection - count:", count);
	
	pos_snap  = count==1
		? [(snap_distance + length-snap_distance) / 2]
		: spread ([snap_distance,length-snap_distance], count, snap_length, between=true);
	pos_tooth = count==1
		? []
		: spread ([snap_distance,length-snap_distance], count, snap_length, between=false);
	
	// Kerbe
	part_add()
	for (p = pos_snap)
	{
		translate_x (p)
	//	rotate ([90,0,+90])
		rotate ([90,0,-90])
		linear_extrude (snap_length, center=true)
		snap_silhouette (height, snap_depth);
	}
	
	// Verzahnung
	part_add()
	for (p = pos_tooth)
	{
		translate_x (p)
		rotate_z (90)
		translate_z (-gap + (height_extra<0 ? height_extra : 0))
		tooth_silhouette (height+abs(height_extra)+gap*1.5, depth+gap, tooth_length);
	}
}

// Lattice grid for refrigerator
module lattice ()
{
	length      = 404;
	depth       = 200;
	lattice_bottom_diameter =  9;
	lattice_diameter        = is_undef(clips_diameter) ? 5.8 : clips_diameter;
	lattice_grid_diameter   =  4.5;
	lattice_distance        = 12;
	lattice_height          = 41;
	lattice_bottom_distance = is_undef(lattice_bottom_distance) ? 0 : lattice_bottom_distance; //-2.5;
	
//	translate ([0, 0                      , lattice_diameter/4])
	translate ([0, lattice_bottom_distance, lattice_diameter  ])
	union()
	{
		rotate_y    (90)
		cylinder_extend (h=length, d=lattice_diameter       , align=Y+X, $fn=48);
		//
		translate_z (-lattice_height)
		translate_y (-lattice_bottom_distance)
		rotate_y    (90)
		cylinder_extend (h=length, d=lattice_bottom_diameter, align=Y-X, $fn=48);
		//
		for (i=[0:1:floor(length/lattice_distance/2)-1])
		{
		mirror_copy_x()
		translate_x ((i+0.5) * lattice_distance)
		translate_z (-lattice_height          + lattice_bottom_diameter)
		translate_y (-lattice_bottom_distance + lattice_bottom_diameter/2)
		rotate_x    (-90)
		cylinder_extend (h=depth, d=lattice_grid_diameter, align=Z);
		}
	}
}


// - Hilfsmodule, könnten möglicherweise zur Bibliothek hinzugefügt werden:


// verteilt eine feste Anzahl an Positionen entlang einer Linie
// - width = Breite des Objekts, Standart = 0
// Position ist die Mitte von width
function spread (line, count, width=0, between=false) =
	(count==undef || count<0) ? undef :
	count==1 ?
		between ? []
		        : [(line[0]+line[1]) / 2]
	:
	let(
		 length         = is_num(line[0]) ?       line[1]-line[0]
		                                  : norm (line[1]-line[0])
		,length_segment = (length-width) / (count-1)
	)
	!between ? [ for (i=[0:1:count-1]) lerp (line[0],line[1], width/2 +  i     *length_segment , length) ]
	         : [ for (i=[0:1:count-2]) lerp (line[0],line[1], width/2 + (i+0.5)*length_segment , length) ]
;

