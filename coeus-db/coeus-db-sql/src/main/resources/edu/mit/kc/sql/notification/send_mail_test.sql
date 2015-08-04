DECLARE
  c UTL_SMTP.CONNECTION;
 
  PROCEDURE send_header(name IN VARCHAR2, header IN VARCHAR2) AS
  BEGIN
    UTL_SMTP.WRITE_DATA(c, name || ': ' || header || UTL_TCP.CRLF);
  END;
 
BEGIN

/*** Working block Begin ***/	
  /*c := UTL_SMTP.OPEN_CONNECTION('outgoing.mit.edu',25); 
  UTL_SMTP.HELO(c, 'outgoing.mit.edu');
  UTL_SMTP.MAIL(c, 'kc-mit-dev@mit.edu');
  UTL_SMTP.RCPT(c, 'kc-mit-dev@mit.edu');
  UTL_SMTP.OPEN_DATA(c);
  send_header('From',    '"Geo Thomas" <geot@mit.edu>');
  send_header('To',      '"KC Dev" <kc-mit-dev@mit.edu>');
  send_header('Subject', 'Test database mail from Geo');
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF || 'Hello, KC DB Mail!');
  UTL_SMTP.CLOSE_DATA(c);
  UTL_SMTP.QUIT(c);*/
 /*** working blcok End ***/
  
/*** Not working block begin ***/
     
KC_MAIL_GENERIC_PKG.SEND_MAIL('kc-mit-dev@mit.edu','geot@mit.edu','kc-mit-dev@mit.edu','Testing MAIl Generic package','Testing Generic Mail package: Mail successful');

/*** Not working block end ***/
END;
/