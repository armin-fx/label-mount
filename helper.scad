include <banded.scad>


// - Projektspezifische Module:

//                     (wall, snap_depth)
module snap_silhouette (height, width)
{
	render()
	difference()
	{
		square ([width, height]);
		//
		triangle (width, side=1);
		//
		translate_y (height-width)
		triangle (width, side=2);
	}
}

//                      (wall, wall_side, 5)
module tooth_silhouette (height, depth, width=5, angle=30)
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

// Put the connection line along the x axis
// where the negative y side is the tooth part
// and the positive y side the plate part.
// Must use in block with 'combine()'
//
//                (length, wall, wall_side, snap_depth, gap, ???)
module connection (length, height, depth, snap_depth, gap=0, height_extra=0)
{
	snap_distance =  3;
	snap_length   = 10;
	tooth_length  =  5;
	//
	count = ceil( (length-2*snap_distance-tooth_length) / (snap_length+tooth_length+snap_distance*2) );
	//echo ("connection - count:", count);
	
	pos_snap  = count==1
		? [(snap_distance + length-snap_distance) / 2]
		: spread ([snap_distance,length-snap_distance], count, snap_length, between=true);
	pos_tooth = count==1
		? []
		: spread ([snap_distance,length-snap_distance], count, snap_length, between=false);
	
	// Kerbe
	part_add()
	for (p = pos_snap)
	{
		translate_x (p)
	//	rotate ([90,0,+90])
		rotate ([90,0,-90])
		linear_extrude (snap_length, center=true)
		snap_silhouette (height, snap_depth);
	}
	
	// Verzahnung
	part_add()
	for (p = pos_tooth)
	{
		translate_x (p)
		rotate_z (90)
		translate_z (-gap + (height_extra<0 ? height_extra : 0))
		tooth_silhouette (height+abs(height_extra)+gap*1.5, depth+gap, tooth_length);
	}
}


// - Hilfsmodule, könnten möglicherweise zur Bibliothek hinzugefügt werden:


// verteilt eine feste Anzahl an Positionen entlang einer Linie
// - width = Breite des Objekts, Standart = 0
// Position ist die Mitte von width
function spread (line, count, width=0, between=false) =
	(count==undef || count<0) ? undef :
	count==1 ?
		between ? []
		        : [(line[0]+line[1]) / 2]
	:
	let(
		 length         = is_num(line[0]) ?       line[1]-line[0]
		                                  : norm (line[1]-line[0])
		,length_segment = (length-width) / (count-1)
	)
	!between ? [ for (i=[0:1:count-1]) lerp (line[0],line[1], width/2 +  i     *length_segment , length) ]
	         : [ for (i=[0:1:count-2]) lerp (line[0],line[1], width/2 + (i+0.5)*length_segment , length) ]
;

// - gap     = the gap between both parts
// - balance = balance between inner and outer parts '-1 ... 0 ... 1'
//              0 = carve out both parts half, default
//             -1 = carve only inner part
//             +1 = carve only outer part
module split_both (gap=0, balance=0)
{
	split_outer(gap, balance) { children(0); children([1:1:$children-1]); }
	split_inner(gap, balance) { children(0); children([1:1:$children-1]); }
}

module split_outer (gap=0, balance=0)
{
	d = gap * (balance+1);
	n = get_slices_circle_current_x (d/2, $fn_min=12);
	//
	difference()
	{
		children([1:1:$children-1]);
		//
		minkowski(convexity=4)
		{
			children(0);
			//
			if (d>0)
		//	sphere (d=d, $fn=12); /*
			rotate_extrude ($fn=n)
			difference()
			{
				circle(d=d);
				translate(-[d+extra,d/2+extra])
				square([d+extra,d+2*extra]);
			} //*/
		}
	}
}

module split_inner (gap=0, balance=0)
{
	d = gap * (1-balance);
	n = get_slices_circle_current_x (d/2, $fn_min=12);
	//
	intersection()
	{
		children([1:1:$children-1]);
		//
		minkowski_difference(convexity=4)
		{
			children(0);
			//
			if (d>0)
		//	sphere (d=d, $fn=12); /*
			rotate_extrude ($fn=n)
			difference()
			{
				circle(d=d);
				translate(-[d+extra,d/2+extra])
				square([d+extra,d+2*extra]);
			} //*/
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
