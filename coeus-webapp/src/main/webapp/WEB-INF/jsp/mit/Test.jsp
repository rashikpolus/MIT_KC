<u>HEADERS</u><br />
 
<table>
<%
java.util.Enumeration eHeaders = request.getHeaderNames();
while(eHeaders.hasMoreElements())
{ String name = (String) eHeaders.nextElement(); 
	Object object = request.getHeader(name); 
	String value = object.toString(); 
	out.println("" + name + "" + value + ""); }
%>
</table>