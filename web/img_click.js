function img_click(s)
{
	var x;
	try 
	{
		x = new ActiveXObject("Msxml2.XMLHTTP");
	} 
	catch (e) 
	{
		try
		{
			x = new ActiveXObject("Microsoft.XMLHTTP");
		}
		catch (E)
		{
			x = false;
		}
	}
	if (!x && typeof XMLHttpRequest!='undefined') 
	{
		x = new XMLHttpRequest();
	}
	x.open("GET","?" + s,true);
	x.send();
}
