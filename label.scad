include <banded.scad>

height = 80;
frame  =  5;
wall      = 1.5;
wall_side = 2.5;
slot      = 1.5;

girder_edge_radius = 4;

gap       = 0.05;
gap_paper = 0.5;

magnet_thickness = 1.1;
magnet_diameter  = 10.1;

/*[Display]*/

show_label_only = true;
show_paper   = false;
show_girder  = false;
show_magnets = false;

/*[Hidden]*/

paper_size  = [ISO_A4.x, ISO_A4.y/4];
paper_space = paper_size + [1,1]*2*gap_paper;
label_size  = [paper_size.x+2*wall_side, height];

magnet_pos =
	[[+paper_space.x/3,paper_space.y/8]
	,[-paper_space.x/3,paper_space.y/8]
	];

echo(paper_size, paper_space);

rotate_x (show_label_only ? 0 : 90)
label();

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
	cylinder (h=magnet_thickness, d=magnet_diameter, $fn=48);
}
if (!show_label_only && show_girder)
{
	length      = 300;
	thickness   =  17;
	wall_girder =   1;
	
	color ("blue", 0.5) %
	difference()
	{
		cube_rounded ([length,thickness,height]
			,align=Y, r=girder_edge_radius, $fn=24
			,edges_side   = 0
			,edges_top    = [1,0,0,0]
			,edges_bottom = [1,0,0,0]
			);
		//
		translate_y (wall_girder+extra)
		cube_rounded ([length+2*extra,thickness-wall_girder+extra,height-2*wall_girder]
			,align=Y, r=girder_edge_radius-wall_girder, $fn=24
			,edges_side   = 0
			,edges_top    = [1,0,0,0]
			,edges_bottom = [1,0,0,0]
			);
	}
}


module label ()
{
	difference()
	{
		cube_chamfer ([label_size.x, label_size.y, wall+slot+wall], align=Z
			,edges=wall*0.8
		//	,edges=configure_edges (default=wall*0.8, bottom=0)
			);
		//
		translate_z (wall)
		cube_extend ([paper_space.x, paper_space.y, slot], align=Z);
		//
		// slot right
		translate ([paper_space.x/2-extra,0,wall])
		cube_extend ([(label_size.x-paper_space.x)/2+2*extra, paper_space.y, slot], align=Z+X);
		//
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
		place_copy (magnet_pos)
		translate_z (-extra)
		cylinder (h=magnet_thickness+gap+extra, d=magnet_diameter+2*gap, $fn=48);
	}
}

//triangle([3,2], side=0);

module triangle (size=[1,1], center, align, side)
{
	Size  = parameter_size_2d(size);
	Align = parameter_align (align, [1,1], center);
	x=Size[0];
	y=Size[1];
	triangle_list=
		side==3 ? [[0,0], [x,y], [0,y]] :
		side==2 ? [[x,0], [x,y], [0,y]] :
		side==1 ? [[0,0], [x,0], [x,y]] :
		          [[0,0], [x,0], [0,y]] ; // side==0 or undef
	
	translate ([for (i=[0:1:len(Size)-1]) (Align[i]-1)*Size[i]/2 ])
	polygon (triangle_list);
}
