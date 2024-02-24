include <banded.scad>

wall  = 1.5;
slot  = 1.5;
frame = 5;

gap = 0.05;

magnet_thickness = 1.1;
magnet_diameter  = 10.1;

paper_size = [ISO_A4.x, 75];

echo(paper_size);

difference()
{
	cube_chamfer ([paper_size.x+2*wall    , paper_size.y+2*wall    , slot+2*wall], r=wall*0.8
		//,edges_bottom = 0
		);
	//
	translate ([wall,wall,wall])
	cube         ([paper_size.x+wall+extra, paper_size.y           , slot]);
//	cube         ([paper_size.x           , paper_size.y+wall+extra, slot]);
	//
	frame_size =  [paper_size.x-2*frame   , paper_size.y-2*frame   , wall+2*extra];
	translate ([wall,wall,wall])
	translate ([frame,frame,slot-extra])
	render(convexity=2)
	union()
	{
		cube (frame_size);
		//
		translate_z (wall*3/5)
		plain_trace_extrude_closed (square_curve([frame_size.x,frame_size.y])) triangle([2*wall,wall], side=3);
	}
	//
	place_copy (
		[[wall,wall]+paper_size/2+[+paper_size.x/3,paper_size.y/8]
		,[wall,wall]+paper_size/2+[-paper_size.x/3,paper_size.y/8]
		])
		translate_z(-extra)
		cylinder (h=magnet_thickness+gap+extra, d=magnet_diameter+2*gap, $fn=48);
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
