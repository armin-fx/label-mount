show_parts = 0; // [ 0:"Complete", 1:"Top part", 2:"Bottom part", 3:"Both parts together", 4:"Test", 5:"Test split object" ]

/*[Measure]*/

frame  =  5;
wall      = 1.5;
wall_side = 2.5;
slot      = 1.5;

gap=0.1;

snap_depth    =  0.5;

length=100;
width=20;

/*[Hidden]*/

include <banded.scad>
include <../helper.scad>

// test BandedScad version
required_version ([2,2,0]);

//!tooth_silhouette(wall, wall_side);

select_object (show_parts)
{
	model();
	split_outer(gap) { split_base(); model(); }
	split_inner(gap) { split_base(); model(); }
	split_both (gap) { split_base(); model(); }
	test  ();
	test_2();
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
	
	translate_y (wall_side) connection (length, wall, wall_side, snap_depth, gap, 0); /*
	
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
		snap_silhouette (wall, snap_depth);
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
	//*/
}

module test  () { connection (length, wall, wall_side, gap, -1); }
module test_2() { split_base(); }

