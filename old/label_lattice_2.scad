// This will create a label for a refrigerator,
// mounted on a strut from the lattice.
//

/* [3D Print] */

show_parts = 0; // [ 0:"Complete", 1:"Top part", 2:"Bottom part", 3:"Both parts together" ]

// if set, the model will lay flat and the other environmental parts will not shown
show_label_only = false;

// If set, this will rotate this object 3d printable. (available if setting show_label_only is set)
lay_flat        = false;

/* [Display] */

show_paper   = true;
show_lattice = true;

/* [Settings] */

flat = false;

/* [Measure] */

height = 50;
frame  =  3;
wall      = 1.5;
wall_side = 2.5;
slot      = 1.5;

gap        = 0.1;
gap_paper  = 0.5;

chamfer_factor = 0.8;

snap_depth    =  0.5;

lattice_diameter        =  5.8;
lattice_bottom_distance = -2.5;

/* [Hidden] */

include <banded.scad>
include <../helper.scad>

paper_size  = [90, 90/2];
paper_space = paper_size + [1,1]*2*gap_paper;
label_size  = [paper_size.x+2*wall_side, height];

chamfer = chamfer_factor * wall;

// test BandedScad version
required_version ([2,2,0]);

// - Compose object with optional environment:

// object_slice(Z, wall+extra ,extra)
rotate_x (
	show_label_only ?
		lay_flat ? 180
		         :   0
	: 90 )
select (show_parts)
{
	label();
	split_outer(gap) { split_base(); label(); }
	split_inner(gap) { split_base(); label(); }
	split_both (gap) { split_base(); label(); }
}

if (!show_label_only && show_paper)
{
	color ("white") %
	rotate_x(90)
	translate_z (wall + 0.1)
	cube_extend ([paper_size.x, paper_size.y, 0.2], align=Z);
}
if (!show_label_only && show_lattice)
{
	color ("lightgrey", 0.5) %
	translate   ([0,-lattice_bottom_distance,-lattice_diameter])
	translate_z (label_size.y/2)
	lattice ();
}

// - Modules:

module label ()
{
	color ("gold")
	difference()
	{
		union()
		{
			// outer hull
			cube_chamfer ([label_size.x, label_size.y, wall+slot+wall], align=Z
				,edges= flat==true
					? configure_edges (default=1, r=chamfer, bottom=1)
					: configure_edges (default=1, r=chamfer, bottom=[0,1,0,1])
				);
			
			// clips
			if (!flat) empty();
		}
		//
		// paper slot
		translate_z (wall)
		cube_extend ([paper_space.x, paper_space.y, slot], align=Z);
		//
		// slot right
		translate ([paper_space.x/2-extra,0,wall])
		cube_extend ([(label_size.x-paper_space.x)/2+2*extra, paper_space.y, slot], align=Z+X);
		//
		// frame window
		frame_size =  [paper_size.x-2*frame   , paper_size.y-2*frame   , wall+2*extra];
		translate_z (wall+slot-extra)
		render(convexity=2)
		union()
		{
			cube_extend (frame_size, align=Z);
			//
			translate_z (wall*3/5)
			plain_trace_extrude_closed
				( square_curve ([frame_size.x,frame_size.y], align=[0,0]) )
				triangle ([2*wall,wall], side=3);
		}
	}
}

module split_base()
{
	// paper plate
	
	// slot right
	
	// snap left
	
	// snap top and bottom
}


