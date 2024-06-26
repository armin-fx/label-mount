// Creates a label for a regal,
// mounted on a girder which holds the board.
//

/* [3D Print] */

show_parts = 0; // [ 0:"Complete", 1:"Top part", 2:"Bottom part", 3:"Both parts together" ]

// if set, the model will lay flat and the other environmental parts will not shown
show_label_only = false;

// If set, this will rotate this object 3d printable. (available if setting show_label_only is set)
lay_flat        = false;

/* [Display] */

show_paper   = true;
show_girder  = true;
show_magnets = true;

/* [Settings] */

// Generate a snag into the rounded edge from the girder
snag = true;

magnets = true;
magnet_count = 4; // [2:1:4]

// If set, generate a groundplate with thinner honeycomp spaces
save_space = true;

/* [Measure] */

height = 80;
frame  =  5;
wall      = 1.5;
wall_side = 2.5;
slot      = 1.5;
slot_snap_height = 0.3;

girder_edge_radius = 5;

gap        = 0.12;
gap_paper  = 0.5;
gap_magnet = 0.05;

chamfer_factor = 0.8;

paper_thickness = 0.1;

magnet_thickness = 1.0;
magnet_diameter  = 10.1;

snap_depth    =  0.5;

// The width of a honeycomp from space pattern if save_space is enabled
honeycomb_width = 8;
// The ratio depth of space to wall thickness in percent. 0% = no space, 100% = hollow space pattern
space_depth_ratio = 50 ;

/* [Hidden] */

include <banded.scad>
include <helper.scad>

// test BandedScad version
required_version ([3,0,0]);

paper_size  = [ISO_A4.x, ISO_A4.y/4];
paper_space = paper_size + [1,1]*2*gap_paper;
label_size  = [paper_size.x+2*wall_side, height];

chamfer = chamfer_factor * wall;

magnet_pos =
	magnet_count==2 ?
		[[+paper_space.x/3,paper_space.y/8]
		,[-paper_space.x/3,paper_space.y/8]
		]:
	magnet_count==3 ?
		[[+paper_space.x/3, paper_space.y/4]
		,[ 0              ,-paper_space.y/4]
		,[-paper_space.x/3, paper_space.y/4]
		]:
	magnet_count==4 ?
		[[+paper_space.x/3, paper_space.y/8]
		,[ 0              , paper_space.y/4]
		,[ 0              ,-paper_space.y/4]
		,[-paper_space.x/3, paper_space.y/8]
		]:
	[];

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
	virtual ("white", alpha=1)
	rotate_x(90)
	translate_z (wall + paper_thickness)
	cube_extend ([paper_size.x, paper_size.y, 4*paper_thickness], align=Z);
}
if (magnets)
if (!show_label_only && show_magnets)
{
	virtual ("lightgrey", alpha=1)
	rotate_x(90)
	place_copy (magnet_pos)
	cylinder_edges_rounded (h=magnet_thickness, d=magnet_diameter, $fn=48
		,edges=0.2
		);
}
if (!show_label_only && show_girder)
{
	length      = 500;
	thickness   =  17;
	wall_girder =   1;
	
	virtual ("blue")
	render()
	difference()
	{
		cube_rounded ([length,thickness,height]
			,align=Y, $fn=24
			,edges=configure_edges (r=girder_edge_radius, forward=[1,1,0,0])
			);
		//
		translate_y (wall_girder+extra)
		cube_rounded ([length+2*extra,thickness-wall_girder+extra,height-2*wall_girder]
			,align=Y, $fn=24
			,edges=configure_edges (r=girder_edge_radius-wall_girder, forward=[1,1,0,0])
			);
	}
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
			,edges= snag==false
				? configure_edges (default=1, r=chamfer, bottom=1)
				: configure_edges (default=1, r=chamfer, bottom=[0,1,0,1])
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
		
		// snag
		if (snag)
		part_add()
		mirror_copy_y()
		translate_y (label_size.y/2)
		difference()
		{
			width = label_size.x - 2*wall*(chamfer_factor/sqrt(2));
			cube_extend ([width, girder_edge_radius, girder_edge_radius/3]
				, align=-Z-Y );
			//
			rotate_y(90)
			cylinder_extend (r=girder_edge_radius, h=width+2*extra
				, align=X-Y
				, outer=1, $fn=12*4 );
		}
		
		// magnet holes
		if (magnets)
		part_cut()
		place_copy (magnet_pos)
		translate_z (-extra)
		cylinder (h=magnet_thickness+extra, d=magnet_diameter+2*gap_magnet, $fn=48);
		
		// save space - generate a grid on backplate with half wall
		space_height    = wall * space_depth_ratio*percent;
		steg_width      = wall * 1.5;
		segment         = steg_width+honeycomb_width;
		k = cos(30);
		if (save_space && space_height>0)
		part_cut()
		difference()
		{
			intersection()
			{
				// honeycomp
				for (x=[0 : segment : paper_size.x/2]) mirror_copy_x()
				place_copy ([[-segment/2,-segment/2*k,0],[0,+segment/2*k,0]])
				for (y=[0 : 2*segment*k : paper_size.y/2+segment*k]) mirror_copy_y()
					translate ([x,y, -extra])
					rotate_z  (30)
					cylinder_extend (h=space_height+extra, d=honeycomb_width, slices=6, outer=1);
				//
				// restrict boundary
				translate_z (-extra)
				cube_extend ([paper_size.x-steg_width, paper_size.y-steg_width*2, wall+extra], align=Z);
				//
			}
			// cut elements
			if (magnets)
			place_copy (magnet_pos)
			translate_z (-extra)
			cylinder (h=space_height+2*extra, d=magnet_diameter+2*(gap_magnet+steg_width+2), $fn=48);
		}
	}
}

module split_base()
combine()
{
	// paper plate
	part_main()
	translate_z (-girder_edge_radius -gap -extra)
	cube_extend ([paper_space.x, paper_space.y, wall+girder_edge_radius +2*gap +2*extra], align=Z);
	
	// slot right
	part_add()
	translate_z (-girder_edge_radius -gap -extra)
	translate_x (paper_space.x/2-extra)
	cube_extend ([(label_size.x-paper_space.x)/2 +gap +2*extra, paper_space.y, wall+girder_edge_radius +2*gap +2*extra], align=Z+X);
	
	if (true)
	{
		// snap left
		translate_xy ([-paper_space.x/2, paper_space.y/2])
		rotate_z(-90)
		connection (paper_space.y, wall, wall_side, snap_depth, gap, -girder_edge_radius);
		
		// snap top and bottom
		mirror_copy_y()
		translate_xy ([-paper_space.x/2, -paper_space.y/2])
		connection (paper_space.x, wall, wall_side, snap_depth, gap, -girder_edge_radius);
	}
	
	if (false)
	{
		snap_distance = 15;
		
		// snap left
		part_add()
		plain_trace_extrude (
			[[-paper_space.x/2, +(paper_space.y/2-snap_distance)]
			,[-paper_space.x/2, -(paper_space.y/2-snap_distance)]
			] )
			snap_silhouette (wall, snap_depth);
		
		// snap top and bottom
		part_add()
		mirror_copy_y()
		plain_trace_extrude (
			[[+(paper_space.x/2-snap_distance), +paper_space.y/2]
			,[-(paper_space.x/2-snap_distance), +paper_space.y/2]
			] )
			snap_silhouette (wall, snap_depth);
	}
}
