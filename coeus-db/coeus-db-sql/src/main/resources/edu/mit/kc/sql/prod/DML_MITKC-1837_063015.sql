UPDATE PROTO_CORRESP_TEMPL
SET CORRESPONDENCE_TEMPLATE = replace(CORRESPONDENCE_TEMPLATE,'/export/home/www/https/tomcat5.0.25/webapps/coeus/images/couhes_byline2.gif',
'/opt/kc/images/couhes_byline2.gif')
WHERE CORRESPONDENCE_TEMPLATE like '%/export/home/www/https/tomcat5.0.25/webapps/coeus/images/couhes_byline2.gif%'
/
