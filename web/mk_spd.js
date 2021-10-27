function mk_spd()
{
	var spd_val = ["80", "120", "300", "450", "700", "1023"];
	document.write("<p style=\"font-size: 250%; font-family: Verdana\">Speed</p>");
	document.write("<table  width=100%><tr>");
	for(var i = 0; i < spd_val.length; i++)
	{
		//document.write("<td><button style=\"width:100%;height:120px;background:#8283c7;color:#ffff8d;font-size:100px;font-weight:600\" onmousedown=img_click(\'spd=" + spd_val[i] + "\')>" + (i+1) + "</button></td>");
		document.write("<td>");
		document.write("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100' onmousedown=img_click(\'spd=" + spd_val[i] + "\')>");
		document.write("<rect width='99' height='99' x='1' y='1' fill='#8283c7' rx='9'/>");
		document.write("<text x='27' y='80' fill='#ffff8d' style='font-size:80px;font-family:Verdana;'>" + (i + 1) + "</text>");
		document.write("</svg>");
		document.write("</td>");
		
	}
	document.write("</tr></table>");
}

