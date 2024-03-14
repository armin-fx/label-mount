// This will create a label for a refrigerator,
// mounted on a strut from the lattice.
//

/* [3D Print] */

show_parts = 0; // [ 0:"Complete", 1:"Top part", 2:"Bottom part", 3:"Both parts together" ]

// If set, the model will lay flat and the other environmental parts will not shown
show_label_only = false;

// If set, this will rotate this object 3d printable. (available if setting show_label_only is set)
lay_flat        = false;

/* [Display] */

show_paper   = true;
show_lattice = true;

/* [Settings] */

clips = true;

/* [Measure] */

height = 35;
frame  =  3;
wall      = 1.5;
wall_side = 2.5;
slot      = 1.5;
slot_snap_height = 0.3;

gap        = 0.1;
gap_paper  = 0.5;
gap_clips  = 0.1;

chamfer_factor = 0.8;

snap_depth    =  0.5;

paper_thickness = 0.1;

lattice_bottom_distance = -2.5;

clips_diameter   = 5.8;
clips_wall       = 2.0;
clips_width      = 10;
clips_snap_width = 0.4;

/* [Hidden] */

include <banded.scad>
include <helper.scad>

paper_size  = [90, 90/3];
paper_space = paper_size + [1,1]*2*gap_paper;
label_size  = [paper_size.x+2*wall_side, height];

label_height = wall + slot + wall;

chamfer = chamfer_factor * wall;

clips_position = paper_space.x/2 * 3/5 ; // * (1-1/euler);

// test BandedScad version
required_version ([2,2,0]);

// - Compose object with optional environment:

// object_slice(Z, wall+extra ,extra)
rotate_x (
	show_label_only ?
		lay_flat ? 180
		         :   0
	: 90 )
select_object (show_parts)
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
	translate_z (wall + paper_thickness)
	cube_extend ([paper_size.x, paper_size.y, 3*paper_thickness], align=Z);
}
if (!show_label_only && show_lattice)
{
	color ("lightgrey", 0.5) %
	translate_z (label_size.y/2)
	lattice ();
}

// - Modules:

module label ()
{
	color ("gold")
	combine()
	{
		// outer hull
		part_main()
		cube_chamfer ([label_size.x, label_size.y, wall+slot+wall], align=Z
			,edges=configure_edges (default=1, r=chamfer, bottom=1)
			);
		
		// paper slot
		part_cut()
		translate_z (wall)
		cube_extend ([paper_space.x, paper_space.y, slot], align=Z);
		
		// slot right
		part_cut()
		difference()
		{
			translate ([paper_space.x/2-extra,0,wall])
			cube_extend ([(label_size.x-paper_space.x)/2+2*extra, paper_space.y, slot], align=Z+X);
			//
			translate ([paper_space.x/2,0,wall+slot+extra])
			cube_chamfer ([(label_size.x-paper_space.x)/2, paper_space.y+2*extra, slot_snap_height+extra], align=-Z+X,
				edges=configure_edges (r=slot_snap_height*sqrt(2), bottom=[0,1,0,1]));
		}
		
		// frame window
		frame_size =  [paper_size.x-2*frame   , paper_size.y-2*frame   , wall+2*extra];
		part_cut()
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
		
		// clips
		if (clips)
		part_add()
		{
			$fd = $preview ? 0.02 : 0.005;
			under                = wall*chamfer_factor;
			side_dist            = label_height+lattice_bottom_distance;
			chamfer_dist         = chamfer * sqrt(1/2);
			clips_outer_diameter = clips_diameter + 2*side_dist;
			//
			bevel_angle = 45;
			//
			clips_angle     = 360 - achord( (clips_diameter - clips_snap_width) / (clips_diameter/2 + gap_clips) );
			clips_angle_gap = clips_angle - 180;
			clips_angle_begin =
				270 - atan(
					(  clips_diameter/2 + lattice_bottom_distance + chamfer_dist)
					/ (clips_diameter/2)
				) ;
			
			mirror_copy_x()
			// position on side
			translate_x (clips_position)
			// position on upper side at front side
			translate   ([0,label_size.y/2,label_height])
			combine()
			{
				// part to remove the chamfered edge of the label
				// and get a straight part to the round clips
				part_add()
				translate_y (-under)
				cube_extend ([clips_width,clips_diameter/2+under,side_dist], align=-Z+Y);
				
				lattice_pos = [0,clips_diameter/2,-side_dist-clips_diameter/2];
				
				// round clips part
				union()
				{
					part_add()
					translate (lattice_pos)  rotate_to_vector (X)
					cylinder_extend (h=clips_width, d=clips_outer_diameter
						, angle=[-clips_angle, clips_angle_begin]
						, center=true );
					//
					part_selfcut()
					cube_extend ([clips_width+2*extra,side_dist,label_height], align=-Z-Y);
					//
					part_selfcut()
					translate   ([0,-chamfer_dist,-label_height])
					cube_extend ([clips_width+2*extra,chamfer+clips_diameter/2,chamfer_dist], align=+Z+Y);
				}
				// bevel edge for better printing in flat position
				part_add()
				rotate_to_vector (X)
				linear_extrude (height=clips_width, center=true)
				polygon(
					[[0,clips_diameter/2]
					,[0,clips_diameter/2 + clips_outer_diameter/2*tan(bevel_angle/2)]
					,rotate_at_z_points ([[0,clips_diameter/2]], -bevel_angle, [clips_outer_diameter/2,clips_diameter/2] ) [0]
					,[clips_outer_diameter/2,clips_diameter/2]
					] );//*/
				//
				// cut lattice out with gap
				part_selfcut_all()
				translate (lattice_pos)  rotate_to_vector (X)
				cylinder_extend (h=clips_width+2*extra, d=clips_diameter+2*gap_clips
					, angle=[-clips_angle, clips_angle_begin]
					, piece=clips_angle<180
					, center=true );
				//
				// clips rounded end
				part_add()
				translate (lattice_pos)  rotate_to_vector (X)
				rotate_z    (clips_angle_begin-clips_angle)
				translate_x (clips_diameter/2+gap_clips)
				union ()
				{
					cylinder_extend (h=clips_width, d=side_dist-gap_clips
						, angle=[180-(clips_angle_gap+16), 180+clips_angle_gap+16]
						, align=X );
					cylinder_extend (h=clips_width, d=side_dist-gap_clips
						, angle=[     clips_angle_gap+16 , 180]
						, align=X, slices=1 );
				}
				
			}
		}
}	}

module split_base()
combine()
{
	// paper plate
	part_main()
	translate_z (-gap -extra)
	cube_extend ([paper_space.x, paper_space.y, wall +2*gap +2*extra], align=Z);
	
	// slot right
	part_add()
	translate_z (-gap -extra)
	translate_x (paper_space.x/2-extra)
	cube_extend ([(label_size.x-paper_space.x)/2 +gap +2*extra, paper_space.y, wall +2*gap +2*extra], align=Z+X);
	
	// snap left
	translate_xy ([-paper_space.x/2, paper_space.y/2])
	rotate_z(-90)
	connection (paper_space.y, wall, wall_side, snap_depth, gap);
	
	// bottom
	translate_xy ([-paper_space.x/2, -paper_space.y/2])
	connection (paper_space.x, wall, wall_side, snap_depth, gap);
	
	// snap top
	translate_xy ([paper_space.x/2, paper_space.y/2])
	rotate_z(180)
	connection (paper_space.x, wall, wall_side, snap_depth, gap);
}

