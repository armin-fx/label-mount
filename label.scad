
/* [Display] */

show_label_only = true;
show_paper   = false;
show_girder  = false;
show_magnets = false;

/* [Settings] */

flat  = false;

split = false;
show_parts = "both"; // ["both", "bottom", "top"]

/* [Measure] */

height = 80;
frame  =  5;
wall      = 1.5;
wall_side = 2.5;
slot      = 1.5;

girder_edge_radius = 4;

gap        = 0.1;
gap_magnet = 0.05;
gap_paper  = 0.5;

chamfer_factor = 0.8;

magnet_thickness = 1.1;
magnet_diameter  = 10.1;

snap_width    =  0.5;
snap_distance = 15;

/* [Hidden] */

include <banded.scad>

paper_size  = [ISO_A4.x, ISO_A4.y/4];
paper_space = paper_size + [1,1]*2*gap_paper;
label_size  = [paper_size.x+2*wall_side, height];

chamfer = chamfer_factor * wall;

magnet_pos =
	[[+paper_space.x/3,paper_space.y/8]
	,[-paper_space.x/3,paper_space.y/8]
	];

echo(paper_size, paper_space);

// - Compose object with optional environment:

// object_slice(Z, wall+extra ,extra)
rotate_x (show_label_only ? 0 : 90)
{
	if (split)
	{
		if (show_parts=="both" || show_parts=="top")    split_top()    label();
		if (show_parts=="both" || show_parts=="bottom") split_bottom() label();
	}
	else
		label();
}

if (!show_label_only && show_paper)
{
	color ("white") %
	rotate_x(90)
	translate_z (wall + 0.1)
	cube_extend ([paper_size.x, paper_size.y, 0.2], align=Z);
}
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
		place_copy (magnet_pos)
		translate_z (-extra)
		cylinder (h=magnet_thickness+gap_magnet+extra, d=magnet_diameter+2*gap_magnet, $fn=48);
	}
}

module split_top ()
{
	difference()
	{
		children();
		//
		minkowski()
		{
			split_base();
			sphere (d=gap/2, $fn=12);
		}
	}
}

module split_bottom ()
{
	intersection()
	{
		children();
		//
		minkowski_difference(convexity=3)
		{
			split_base();
			sphere (d=gap/2, $fn=12);
		}
	}
}

module split_base()
{
	// paper plate
	translate_z (-girder_edge_radius -gap -extra)
	cube_extend ([paper_space.x, paper_space.y, wall+girder_edge_radius +2*gap +2*extra], align=Z);
	
	// slot right
	translate_z (-girder_edge_radius -gap -extra)
	translate_x (paper_space.x/2-extra)
	cube_extend ([(label_size.x-paper_space.x)/2 +gap +2*extra, paper_space.y, wall+girder_edge_radius +2*gap +2*extra], align=Z+X);
	
	// snap left
	plain_trace_extrude (
		[[-paper_space.x/2, +(paper_space.y/2-snap_distance)]
		,[-paper_space.x/2, -(paper_space.y/2-snap_distance)]
		] )
		snap_silhouette ();
	
	// snap top and bottom
	mirror_copy_y()
	plain_trace_extrude (
		[[+(paper_space.x/2-snap_distance), +paper_space.y/2]
		,[-(paper_space.x/2-snap_distance), +paper_space.y/2]
		] )
		snap_silhouette ();
}

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

