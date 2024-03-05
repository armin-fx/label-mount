include <banded.scad>


// - Projektspezifische Module:




// - Hilfsmodule, könnten möglicherweise zur Bibliothek hinzugefügt werden:


// verteilt eine feste Anzahl an Positionen entlang einer Linie
// - width = Breite des Objekts, Standart = 0
// Position ist die Mitte von width
function spread (line, count, width=0, between=false) =
	(count==undef || count<0) ? undef :
	count==1 ? [(line[0]+line[1]) / 2] :
	let(
		 length         = is_num(line[0]) ?       line[1]-line[0]
		                                  : norm (line[1]-line[0])
		,length_segment = (length-width) / (count-1)
	)
	!between ? [ for (i=[0:1:count-1]) lerp (line[0],line[1], width/2 +  i     *length_segment , length) ]
	         : [ for (i=[0:1:count-2]) lerp (line[0],line[1], width/2 + (i+0.5)*length_segment , length) ]
;

module split_both (gap=0)
{
	split_outer(gap) { children(0); children([1:1:$children-1]); }
	split_inner(gap) { children(0); children([1:1:$children-1]); }
}

module split_outer (gap=0)
{
	difference()
	{
		 children([1:1:$children-1]);
		//
		minkowski(convexity=4)
		{
			children(0);
		//	sphere (d=gap/2, $fn=12);
			rotate_extrude($fn=12)
			difference()
			{
				circle(d=gap);
				translate(-[gap+extra,gap/2+extra])
				square([gap+extra,gap+2*extra]);
			}
		}
	}
}

module split_inner (gap=0)
{
	intersection()
	{
		 children([1:1:$children-1]);
		//
		minkowski_difference(convexity=4)
		{
			children(0);
		//	sphere (d=gap/2, $fn=12);
			rotate_extrude($fn=12)
			difference()
			{
				circle(d=gap);
				translate(-[gap+extra,gap/2+extra])
				square([gap+extra,gap+2*extra]);
			}
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
