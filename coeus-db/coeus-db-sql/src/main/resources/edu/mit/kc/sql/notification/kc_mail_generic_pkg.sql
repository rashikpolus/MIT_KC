create or replace PACKAGE KC_MAIL_GENERIC_PKG is              
  gs_mail_host                  VARCHAR2(250);
  gs_mail_port                  VARCHAR2(250);
  gs_mail_sender                VARCHAR2(250);
  gs_mail_reply                VARCHAR2(250);
  
 FUNCTION FN_NOTIFICATION_IS_ACTIVE(AV_NOTIFICATION_TYPE_ID IN NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%TYPE , 
									 AV_MODULE_CODE IN NOTIFICATION_TYPE.MODULE_CODE%TYPE ,
									 AV_ACTION_CODE IN NOTIFICATION_TYPE.ACTION_CODE%TYPE)
									 RETURN NUMBER;  
									 
 PROCEDURE GET_NOTIFICATION_TYP_DETS(AV_NOTIFICATION_TYPE_ID IN OUT NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%TYPE , 
									 AV_MODULE_CODE IN NOTIFICATION_TYPE.MODULE_CODE%TYPE ,
									 AV_ACTION_CODE IN NOTIFICATION_TYPE.ACTION_CODE%TYPE,
									 AV_SUBJECT OUT  NOTIFICATION_TYPE.SUBJECT%TYPE,
									 AV_MESSAGE OUT  NOTIFICATION_TYPE.MESSAGE%TYPE );
									 
 PROCEDURE	SEND_MAIL( AV_NOTIFICATION_TYPE_ID IN NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%TYPE , 
					   AV_RECIPIENTS IN VARCHAR2,
                       AV_COPY_TO   IN  VARCHAR2,
					   AV_REPLY_TO  IN  VARCHAR2,
					   AV_SUBJECT IN NOTIFICATION_TYPE.SUBJECT%TYPE,
					   AV_MESSAGE IN CLOB );							 
									 
 FUNCTION FN_INSERT_KREN_NTFCTN(   AV_NOTIFICATION_TYPE_ID IN NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%TYPE ,
								  AV_NOTIF_MODULE IN VARCHAR2,
								  AV_MESSAGE IN CLOB)
								  RETURN NUMBER;
								  
 PROCEDURE FN_INSRT_KREN_NTFCTN_MSG_DELIV( AV_NOTIFICATION_TYPE_ID IN NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%TYPE ,
										  AV_NTFCTN_ID IN NUMBER,
										  AV_RECIP_PERS_ID IN VARCHAR2,
										  AV_MAIL_SENT_STATUS IN CHAR);	
										  
/* commented because KC is currently not using this table
PROCEDURE FN_INSRT_NOTIFICATION( AV_NOTIFICATION_TYPE_ID IN NOTIFICATION.NOTIFICATION_TYPE_ID%TYPE,
								 AV_DOCUMENT_NUMBER IN NOTIFICATION.DOCUMENT_NUMBER%TYPE,
								 AV_SUBJECT 		IN NOTIFICATION.SUBJECT%TYPE,
								 AV_MESSAGE 		IN NOTIFICATION.MESSAGE%TYPE );		
*/
								
									 
end;
/
create or replace PACKAGE BODY KC_MAIL_GENERIC_PKG  AS

/*
This function checks whether notification is active or not . returns '1' if Active else '0'
*/
 FUNCTION FN_NOTIFICATION_IS_ACTIVE(AV_NOTIFICATION_TYPE_ID IN  NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%TYPE , 
									 AV_MODULE_CODE IN NOTIFICATION_TYPE.MODULE_CODE%TYPE ,
									 AV_ACTION_CODE IN NOTIFICATION_TYPE.ACTION_CODE%TYPE)	
								RETURN NUMBER									 
IS
li_count PLS_INTEGER;
BEGIN

	 IF AV_NOTIFICATION_TYPE_ID is NULL THEN
		 SELECT count(notification_type_id) INTO li_count
		 FROM NOTIFICATION_TYPE
		 WHERE MODULE_CODE = AV_MODULE_CODE
		 AND   ACTION_CODE = AV_ACTION_CODE
		 AND   SEND_NOTIFICATION = 'Y';
    ELSE
		 SELECT count(notification_type_id) INTO li_count
		 FROM NOTIFICATION_TYPE
		 WHERE NOTIFICATION_TYPE_ID = AV_NOTIFICATION_TYPE_ID
		 AND SEND_NOTIFICATION = 'Y';
	END IF;

	if li_count = 0 then
		return 0;
	end if;

	return 1;	
	
EXCEPTION
WHEN OTHERS THEN
RETURN 0;

END;

/*
This procedure will return mail subject and message
*/
 PROCEDURE GET_NOTIFICATION_TYP_DETS( AV_NOTIFICATION_TYPE_ID IN OUT NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%TYPE , 
									 AV_MODULE_CODE IN NOTIFICATION_TYPE.MODULE_CODE%TYPE ,
									 AV_ACTION_CODE IN NOTIFICATION_TYPE.ACTION_CODE%TYPE,
									 AV_SUBJECT OUT  NOTIFICATION_TYPE.SUBJECT%TYPE,
									 AV_MESSAGE OUT  NOTIFICATION_TYPE.MESSAGE%TYPE )  IS
 BEGIN
 
 
 IF AV_NOTIFICATION_TYPE_ID is NULL THEN
     SELECT NOTIFICATION_TYPE_ID,SUBJECT,MESSAGE INTO AV_NOTIFICATION_TYPE_ID,AV_SUBJECT, AV_MESSAGE 
	 FROM NOTIFICATION_TYPE
	 WHERE MODULE_CODE = AV_MODULE_CODE
	 AND   ACTION_CODE = AV_ACTION_CODE
	 AND   SEND_NOTIFICATION = 'Y';
	 
 ELSE
     SELECT SUBJECT,MESSAGE INTO AV_SUBJECT, AV_MESSAGE 
	 FROM NOTIFICATION_TYPE
	 WHERE NOTIFICATION_TYPE_ID = AV_NOTIFICATION_TYPE_ID
	 AND SEND_NOTIFICATION = 'Y';
 
 
 END IF;
 
  
 EXCEPTION
 WHEN OTHERS THEN
 AV_SUBJECT 			 := null;
 AV_MESSAGE 			 := null;
 AV_NOTIFICATION_TYPE_ID := null;
 
 END GET_NOTIFICATION_TYP_DETS;
 
 -- This procedure will send emails

 PROCEDURE SEND_MAIL(  AV_NOTIFICATION_TYPE_ID IN NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%TYPE ,
					   AV_RECIPIENTS IN VARCHAR2,
                       AV_COPY_TO   IN  VARCHAR2,
					   AV_REPLY_TO  IN  VARCHAR2,
					   AV_SUBJECT IN NOTIFICATION_TYPE.SUBJECT%TYPE,
					   AV_MESSAGE IN CLOB )
IS  
mail_conn              utl_smtp.connection; 
mesg                   clob;
crlf                   VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );
tab                    varchar2(1) := chr(9);
ls_MailMode            varchar2(2);
ls_TestMailReceiver    varchar2(256);
ls_recipients          varchar2(2000);
ls_Allrecipients       varchar2(2000);
li_pos                 number;
ls_emailid             varchar2(200);
 v_len integer;
 v_cur_pos number := 1;
BEGIN 


	BEGIN
        select VAL  into gs_mail_host
        from KRCR_PARM_T
        where PARM_NM = 'KC_DB_MAIL_HOST'
		AND  nmspc_cd ='KC-GEN';
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20101,'Error Generating Email. Parameter KC_DB_MAIL_HOST not found in parameter table'  );
            return;
    END;

	BEGIN
        select VAL  into gs_mail_port
        from KRCR_PARM_T
        where PARM_NM = 'KC_DB_MAIL_PORT'
		AND  nmspc_cd ='KC-GEN';
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20101,'Error Generating Email. Parameter KC_DB_MAIL_PORT not found in parameter table'  );
            return;
    END;
	
	BEGIN
        select VAL  into gs_mail_sender
        from KRCR_PARM_T
        where PARM_NM = 'KC_DB_SENDER_ID'
		AND  nmspc_cd ='KC-GEN';
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20101,'Error Generating Email. Parameter KC_DB_SENDER_ID not found in parameter table'  );
            return;
    END;
		
	
     BEGIN
        select VAL  into ls_MailMode
        from KRCR_PARM_T
        where PARM_NM = 'EMAIL_NOTIFICATIONS_TEST_ENABLED'
		AND  nmspc_cd ='KC-GEN';
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20101,'Error Generating Email. Parameter EMAIL_NOTIFICATION_TEST_ENABLED not found in parameter table'  );
            return;
    END;

    BEGIN
        select VAL into ls_TestMailReceiver
        from KRCR_PARM_T
        where PARM_NM = 'EMAIL_NOTIFICATION_TEST_ADDRESS'
		AND  nmspc_cd ='KC-GEN';
    EXCEPTION
        WHEN OTHERS THEN
		raise_application_error(-20101, 'Error Generating Email. Parameter EMAIL_NOTIFICATION_TEST_ADDRESS not found in parameter table' );
            return;
    END;

	 BEGIN
        select VAL into gs_mail_reply
        from KRCR_PARM_T
        where PARM_NM = 'KC_DB_REPLY_ID'
		AND  nmspc_cd ='KC-GEN';
    EXCEPTION
        WHEN OTHERS THEN
		raise_application_error(-20101, 'Error Generating Email. Parameter KC_DB_REPLY_ID not found in parameter table' );
            return;
    END;
	
    ls_recipients := AV_RECIPIENTS;
    ls_Allrecipients := AV_RECIPIENTS;
	
	if AV_REPLY_TO is not null then
		gs_mail_reply := AV_REPLY_TO ;
	end if;	
	
    mail_conn := utl_smtp.open_connection(gs_mail_host, gs_mail_port);
    utl_smtp.helo(mail_conn, gs_mail_host);
    utl_smtp.mail(mail_conn, gs_mail_sender);

     IF ls_MailMode = 'Y' THEN
        utl_smtp.rcpt(mail_conn, ls_TestMailReceiver);
    else

          loop
            li_pos := instr(ls_recipients, ',');
            if li_pos = 0 then
                utl_smtp.rcpt(mail_conn, ls_recipients);
                exit;
            else

                ls_EmailId := substr(ls_recipients, 1, li_pos - 1);
                utl_smtp.rcpt(mail_conn, ls_EmailId);
                ls_recipients := substr(ls_recipients, li_pos + 1);

                if (length(ls_recipients) < 1) or  (ls_recipients is null)
      then
                    exit;
                end if;

            end if;
        end loop;

        --Add test mail recipient as a recipient to the email
        utl_smtp.rcpt(mail_conn, ls_TestMailReceiver);
    END IF;


    utl_smtp.open_data(mail_conn);
    
    mesg :=     'From:'|| 'MIT KC Application' || crlf ||
                'Reply-To:'||gs_mail_reply  || crlf;
                
    if ls_MailMode = 'N' then
        mesg := mesg || 'CC:'|| AV_COPY_TO  || crlf;
    end if;                
    
    mesg :=  mesg || 'BCC:'||ls_TestMailReceiver  || crlf ||
                'Content-Type: text/html' || crlf;
                
   mesg := mesg || 'Subject:' || AV_SUBJECT || crlf;

    IF ls_MailMode = 'N' THEN
        mesg := mesg || 'To: '|| ls_Allrecipients || crlf;
    ELSE
        mesg := mesg || 'To: '|| ls_TestMailReceiver || crlf;
    END IF;

    mesg := mesg || '' || crlf || crlf ;

    IF ls_MailMode = 'Y' THEN
        mesg := mesg ||
      '<p>-----------------------------------------------------</p>' || crlf
      ||
                             'In Production mode this mail will be sent to '
      || ls_Allrecipients || crlf;
      
      if AV_COPY_TO is not null then
        mesg := mesg || ' And copied to ' || AV_COPY_TO || crlf;
      end if;
      
      mesg := mesg || '<p>-----------------------------------------------------</p>' || crlf ;
    END IF;
    
    utl_smtp.write_data(mail_conn, mesg); 
    
    --split message into 25k byte chunks  start
      v_len := DBMS_LOB.getlength(AV_MESSAGE);
      while v_cur_pos <= v_len 
      loop       
        UTL_SMTP.WRITE_DATA(mail_conn, DBMS_LOB.SUBSTR(AV_MESSAGE,32000,v_cur_pos));  
        v_cur_pos := v_cur_pos + 32000;
      end loop;
    --- utl_smtp.write_data(mail_conn, AV_MESSAGE);  
    -- split message into 25k byte chunks  Ends
     
    utl_smtp.close_data(mail_conn);
    utl_smtp.quit(mail_conn);
 
 EXCEPTION
  WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
    BEGIN
      UTL_SMTP.QUIT(mail_conn);
    EXCEPTION
      WHEN UTL_SMTP.TRANSIENT_ERROR OR UTL_SMTP.PERMANENT_ERROR THEN
        NULL;         
    END;
    raise_application_error(-20000,  'Failed to send mail due to the following error: ' || sqlerrm);  
  
  END SEND_MAIL;
  
/*
This will insert notification details to KREN_NTFCTN_T
*/  
FUNCTION FN_INSERT_KREN_NTFCTN( AV_NOTIFICATION_TYPE_ID IN NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%TYPE ,
								AV_NOTIF_MODULE IN VARCHAR2,
								AV_MESSAGE IN CLOB)
								RETURN NUMBER
IS
ls_ttl   KREN_NTFCTN_T.TTL%TYPE;
ls_cntnt KREN_NTFCTN_T.CNTNT%TYPE;
li_ntfctn_id KREN_NTFCTN_T.NTFCTN_ID%TYPE;
BEGIN
ls_ttl := AV_NOTIF_MODULE;

ls_cntnt := q'< <content xmlns="ns:notification/ContentTypeSimple" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="ns:notification/ContentTypeSimple resource:notification/ContentTypeSimple"><message><![CDATA[ >'||AV_MESSAGE||q'<  .]]></message></content>>';

li_ntfctn_id := KREN_NTFCTN_S.NEXTVAL;

INSERT INTO KREN_NTFCTN_T(
	NTFCTN_ID,
	DELIV_TYP,
	CRTE_DTTM,
	SND_DTTM,	
	PRIO_ID,
	TTL,
	CNTNT,
	CNTNT_TYP_ID,
	CHNL_ID,
	PRODCR_ID,
	PROCESSING_FLAG	,
	VER_NBR,
	OBJ_ID,
	DOC_TYP_NM
)
VALUES(
	li_ntfctn_id,
	'FYI',
	sysdate,
	sysdate,
	1,
	ls_ttl,
	ls_cntnt,
	1,
	1000,
	1000,
	'RESOLVED',
	1,
	SYS_GUID(),
	'KcNotificationDocument'
);

return li_ntfctn_id;

EXCEPTION
WHEN OTHERS THEN
RETURN -1;

END;
/*
This will insert to KREN_NTFCTN_MSG_DELIV_T
*/ 	
PROCEDURE FN_INSRT_KREN_NTFCTN_MSG_DELIV(AV_NOTIFICATION_TYPE_ID IN NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%TYPE , 
										 AV_NTFCTN_ID IN NUMBER,
										 AV_RECIP_PERS_ID IN VARCHAR2,
										 AV_MAIL_SENT_STATUS IN CHAR)								
IS
li_count NUMBER;
BEGIN

select count(NTFCTN_MSG_DELIV_ID) into li_count from KREN_NTFCTN_MSG_DELIV_T where NTFCTN_ID = AV_NTFCTN_ID and RECIP_ID = AV_RECIP_PERS_ID;
if li_count = 0 then
begin
	INSERT INTO KREN_NTFCTN_MSG_DELIV_T(
		NTFCTN_MSG_DELIV_ID,
		NTFCTN_ID,
		RECIP_ID,
		STAT_CD,
		SYS_ID,
		LOCKD_DTTM,
		VER_NBR,
		OBJ_ID
	)
	VALUES(
		KREN_NTFCTN_MSG_DELIV_S.NEXTVAL,
		AV_NTFCTN_ID,
		AV_RECIP_PERS_ID,
		decode(AV_MAIL_SENT_STATUS,'Y','DELIVERED','FAILED'),
		NULL,
		NULL,
		1,
		SYS_GUID()
	);
exception
when others then
null;
end;
end if;	

END;				  
/*
insert notification details to Notification table
*/
/* commented because KC is currently not using this table
PROCEDURE FN_INSRT_NOTIFICATION( AV_NOTIFICATION_TYPE_ID IN NOTIFICATION.NOTIFICATION_TYPE_ID%TYPE,
								 AV_DOCUMENT_NUMBER IN NOTIFICATION.DOCUMENT_NUMBER%TYPE,
								 AV_SUBJECT 		IN NOTIFICATION.SUBJECT%TYPE,
								 AV_MESSAGE 		IN NOTIFICATION.MESSAGE%TYPE )
IS
BEGIN

INSERT INTO NOTIFICATION(
	NOTIFICATION_ID,
	NOTIFICATION_TYPE_ID,
	DOCUMENT_NUMBER,
	SUBJECT,
	MESSAGE,
	UPDATE_USER,
	UPDATE_TIMESTAMP,
	VER_NBR,
	OBJ_ID
)
VALUES(
	SEQ_NOTIFICATION_ID.NEXTVAL,
	AV_NOTIFICATION_TYPE_ID,
	AV_DOCUMENT_NUMBER,
	AV_SUBJECT,
	AV_MESSAGE,
	user,
	sysdate,
	1,
	sys_guid()
);
EXCEPTION WHEN OTHERS THEN
NULL;

END;
*/								 
END KC_MAIL_GENERIC_PKG;
/