include <banded.scad>

choice = 0; // [ 0:"Complete", 1:"Top part", 2:"Bottom part", 3:"Both parts together" ]

/*[Measure]*/

frame  =  5;
wall      = 1.5;
wall_side = 2.5;
slot      = 1.5;

gap=0.1;

snap_width    =  0.5;
snap_distance = 15;

length=100;
width=20;

//!tooth_silhouette(wall, wall_side);

select (choice)
{
	model();
	split_top()    model();
	split_bottom() model();
	split_both()   model();
}


module model () combine()
{
	// Basisplatte
	part_main()
	cube([length,width,wall]);
	
	// Wand
	part_add()
	translate_z (wall)
	cube([length,wall_side,slot]);
	
	// Rahmen
	part_add()
	translate_z (wall + slot)
	cube([length,frame,wall]);
	
	// Markierung
	part_cut()
	translate_z (wall - 0.5)
	linear_extrude     (0.5 + extra)
	translate ([10,7])
	text("Test");
}

module split_base() combine()
{
	// Basisplatte ohne Wand
	part_main()
	translate_y (wall_side)
	translate (-gap*[1,0,1])
	cube([length,width-wall_side,wall] + A*2*gap);
	
	// Kerbe
	snap_distance = 3;
	snap_length = 10;
	count = 5;
	part_add()
	for (p = spread([snap_distance,length-snap_distance], count, snap_length, between=true) )
	{
		translate_x (p)
		translate_y (wall_side)
	//	rotate ([90,0,+90])
		rotate ([90,0,-90])
		linear_extrude (snap_length, center=true)
		snap_silhouette ();
	}
	
	// Verzahnung
	part_add()
	for (p = spread([snap_distance,length-snap_distance], count, snap_length, between=false) )
	{
		translate_x (p)
		translate_y (wall_side)
		rotate_z (90)
		translate_z (-gap)
		tooth_silhouette (wall+gap*1.5, wall_side+gap, 5);
	}
}

echo( "spread:", spread ([0,5], 3, 1 ) );

// verteilt eine feste Anzahl an Positionen entlang einer Linie
// - width = Breite des Objekts, Standart = 0
// Position ist die Mitte von width
function spread (line, count, width=0, between=false) =
	(count==undef || count<0) ? undef :
	count==1 ? [(line[0]+line[1]) / 2] :
	let(
		 length         = is_num(line[0]) ?       line[1]-line[0]
		                                  : norm (line[1]-line[0])
		,length_segment = (length-width) / (count-1)
	)
	!between ? [ for (i=[0:1:count-1]) lerp (line[0],line[1], width/2 +  i     *length_segment , length) ]
	         : [ for (i=[0:1:count-2]) lerp (line[0],line[1], width/2 + (i+0.5)*length_segment , length) ]
;

module snap_silhouette ()
{
	render()
	difference()
	{
		square ([snap_width, wall]);
		//
		triangle (snap_width, side=1);
		//
		translate_y (wall-snap_width)
		triangle (snap_width, side=2);
	}
}

module tooth_silhouette (height, depth, width=8, angle=30)
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

module split_both ()
{
	split_top()    children();
	split_bottom() children();
}

module split_top ()
{
	difference()
	{
		children();
		//
		minkowski(convexity=4)
		{
			split_base();
		//	sphere (d=gap/2, $fn=12);
			rotate_extrude($fn=12)
			difference()
			{
				circle(d=gap);
				translate(-[gap+extra,gap/2+extra])
				square([gap+extra,gap+2*extra]);
			}
		}
	}
}

module split_bottom ()
{
	intersection()
	{
		children();
		//
		minkowski_difference(convexity=4)
		{
			split_base();
		//	sphere (d=gap/2, $fn=12);
			rotate_extrude($fn=12)
			difference()
			{
				circle(d=gap);
				translate(-[gap+extra,gap/2+extra])
				square([gap+extra,gap+2*extra]);
			}
		}
	}
}

module select (i)
{
	if (i!=undef && is_num(i))
	    if (i>=0) children (i);
		else      children ($children-i);
	else if (i!=undef && is_list(i))
		for (j=i) children (j);
	else          children ();
}

