
/* [Display] */

show_label_only = true;

show_paper   = true;
show_lattice = true;

/* [Settings] */

flat  = false;

show_parts = 0; // [ 0:"Complete", 1:"Top part", 2:"Bottom part", 3:"Both parts together" ]

/* [Measure] */

height = 35;
frame  =  3;
wall      = 1.5;
wall_side = 2.5;
slot      = 1.5;

lattice_diameter = 6;
lattice_bottom_distance = -2.5;

gap        = 0.1;
gap_paper  = 0.5;
gap_clips  = 0.2;

chamfer_factor = 0.8;

snap_depth    =  0.5;

/* [Hidden] */

include <banded.scad>
include <helper.scad>

paper_size  = [90, 90/3];
paper_space = paper_size + [1,1]*2*gap_paper;
label_size  = [paper_size.x+2*wall_side, height];

label_height = wall + slot + wall;

chamfer = chamfer_factor * wall;

// test BandedScad version
required_version ([2,2,0]);

// - Compose object with optional environment:

// object_slice(Z, wall+extra ,extra)
rotate_x (show_label_only ? 0 : 90)
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
	length      = 404;
	depth       = 200;
	lattice_bottom_diameter =  9;
	lattice_distance        = 20;
	lattice_height          = 41;
	
	color ("lightgrey", 0.5) %
//	translate ([0, 0                      , lattice_diameter/4])
	translate ([0, lattice_bottom_distance, lattice_diameter  ])
	union()
	{
		translate_z (label_size.y/2)
		rotate_y    (90)
		cylinder_extend (h=length, d=lattice_diameter       , align=Y+X, $fn=48);
		//
		translate_z (label_size.y/2 - lattice_height)
		translate_y (-lattice_bottom_distance)
		rotate_y    (90)
		cylinder_extend (h=length, d=lattice_bottom_diameter, align=Y-X, $fn=48);
		//
		for (i=[0:1:floor(length/lattice_distance/2)-1])
		{
		mirror_copy_x()
		translate_x ((i+0.5) * lattice_distance)
		translate_z (label_size.y/2 - lattice_height + lattice_bottom_diameter)
		translate_y (-lattice_bottom_distance + lattice_bottom_diameter/2)
		rotate_x    (-90)
		cylinder_extend (h=depth, d=lattice_diameter, align=Z);
		}
	}
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
					: configure_edges (default=1, r=chamfer, bottom=[0,1,1,1])
				);
			
			// clips
			if (!flat)
			{
				clips_width = 10;
				clips_angle = 180 + 10;
				//
				$fd = 0.02;
				under = wall*chamfer_factor;
				side_dist = label_height+lattice_bottom_distance;
				chamfer_dist = chamfer * sqrt(1/2);
				lattice_angle =
					270 - atan(
						(  lattice_diameter/2 + lattice_bottom_distance + chamfer_dist)
						/ (lattice_diameter/2)
					) ;
				//
				mirror_copy_x()
				// position on side
				translate_x (paper_space.x/2 * (1-1/euler))
				// position on upper side at front side
				translate   ([0,label_size.y/2,label_height])
				combine()
				{
					part_add()
					translate_y (-under)
					cube_extend ([clips_width,lattice_diameter/2+under,side_dist], align=-Z+Y);
					
					lattice_pos = [0,lattice_diameter/2,-side_dist-lattice_diameter/2];
					
					union()
					{
						part_add()
						translate (lattice_pos)  rotate_to_vector (X)
						cylinder_extend (h=clips_width, d=lattice_diameter+2*side_dist
							, angle=[-clips_angle,lattice_angle]
							, center=true );
						//
						part_selfcut()
						cube_extend ([clips_width+2*extra,side_dist,label_height], align=-Z-Y);
						//
						part_selfcut()
						translate   ([0,-chamfer_dist,-label_height])
						cube_extend ([clips_width+2*extra,chamfer+lattice_diameter/2,chamfer_dist], align=+Z+Y);
					}
					//
					part_selfcut_all()
					translate (lattice_pos)  rotate_to_vector (X)
					cylinder_extend (h=clips_width+2*extra, d=lattice_diameter+2*gap_clips
						, angle=[-clips_angle,lattice_angle]
						, piece=clips_angle<180
						, center=true );
					//
					part_add()
					translate (lattice_pos)  rotate_to_vector (X)
					rotate_z    (lattice_angle-clips_angle)
					translate_x (lattice_diameter/2+gap_clips)
					cylinder_extend (h=clips_width, d=side_dist-gap_clips
						, angle=[180,180]
						, align=X );
					
				}
			}
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

