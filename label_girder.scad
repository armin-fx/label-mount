
/* [Display] */

show_parts = 0; // [ 0:"Complete", 1:"Top part", 2:"Bottom part", 3:"Both parts together" ]

// if set, the model will lay flat and the other environmental parts will not shown
show_label_only = true;

show_paper   = true;
show_girder  = true;
show_magnets = true;

/* [3D Print] */

// this has only an effect if setting show_label_only is set
lay_flat = false;

/* [Settings] */

flat  = false;

magnets = true;

save_space = false;

/* [Measure] */

height = 80;
frame  =  5;
wall      = 1.5;
wall_side = 2.5;
slot      = 1.5;

girder_edge_radius = 5;

gap        = 0.1;
gap_magnet = 0.05;
gap_paper  = 0.5;

chamfer_factor = 0.8;

magnet_thickness = 1.1;
magnet_diameter  = 10.1;

snap_width    =  0.5;

/* [Hidden] */

include <banded.scad>
include <helper.scad>

paper_size  = [ISO_A4.x, ISO_A4.y/4];
paper_space = paper_size + [1,1]*2*gap_paper;
label_size  = [paper_size.x+2*wall_side, height];

chamfer = chamfer_factor * wall;

magnet_pos =
	[[+paper_space.x/3,paper_space.y/8]
	,[-paper_space.x/3,paper_space.y/8]
	];

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
if (magnets)
if (!show_label_only && show_magnets)
{
	color ("lightgrey") %
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
	
	color ("blue", 0.5) %
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
			
			// snag
			if (!flat)
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
		//
		// magnet holes
		if (magnets)
		place_copy (magnet_pos)
		translate_z (-extra)
		cylinder (h=magnet_thickness+extra, d=magnet_diameter+2*gap_magnet, $fn=48);
		//
		// save space - generate a grid on backplate with half wall
		space_height    = wall/2;
		steg_width      = wall * 2;
		honeycomb_width = 10;
		segment         = steg_width+honeycomb_width;
		k = cos(30);
		if (save_space)
		difference()
		{
			intersection()
			{
				// honeycomp
				for (x=[0 : segment : paper_size.x/2]) mirror_copy_x()
				place_copy ([[-segment/2,-segment/2*k,0],[0,+segment/2*k,0]])
				for (y=[0 : 2*segment*k : paper_size.y/2]) mirror_copy_y()
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
		connection (paper_space.y, wall, wall_side, gap, -girder_edge_radius);
		
		// snap top and bottom
		mirror_copy_y()
		translate_xy ([-paper_space.x/2, -paper_space.y/2])
		connection (paper_space.x, wall, wall_side, gap, -girder_edge_radius);
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
			snap_silhouette (wall, snap_width);
		
		// snap top and bottom
		part_add()
		mirror_copy_y()
		plain_trace_extrude (
			[[+(paper_space.x/2-snap_distance), +paper_space.y/2]
			,[-(paper_space.x/2-snap_distance), +paper_space.y/2]
			] )
			snap_silhouette (wall, snap_width);
	}
}
