function mk_dir()
{
	var dirs =
	[
		["OP","PP","PO"],
		["NP","OO","PN"],
		["ON","NN","NO"],
	];
	var i,j;
	document.write("<p style=\"font-size: 250%; font-family: Verdana\">Direction</p>");
	document.write("<table  width=100%>");
	for(i = 0; i < 3; i++)
	{
		document.write("<tr>");
		for(j = 0; j < 3; j++)
		{
			document.write("<td><svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100' onmousedown=\"img_click('dir=" + dirs[i][j] + "')\">");
			document.write("<rect width='99' height='99' x='1' y='1' fill='#8283c7' rx='9'/>");
			write_arrow(i,j);
			document.write("</svg></td>");
		}
		document.write("</tr>");
	}
	document.write("</table>");
	
}
