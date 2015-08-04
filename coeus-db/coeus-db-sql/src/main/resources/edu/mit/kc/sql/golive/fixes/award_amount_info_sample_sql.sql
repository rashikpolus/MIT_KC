  		SELECT AWARD_AMOUNT_INFO.OBLIGATION_EXPIRATION_DATE,
         AWARD_AMOUNT_INFO.ANTICIPATED_TOTAL_AMOUNT,
         AWARD_AMOUNT_INFO.AMOUNT_OBLIGATED_TO_DATE
    	FROM AWARD_AMOUNT_INFO
		WHERE AWARD_AMOUNT_INFO.AWARD_NUMBER = '022882-00001' 
		AND     AWARD_AMOUNT_INFO.AWARD_AMOUNT_INFO_ID = ( select max(t1.AWARD_AMOUNT_INFO_ID) from AWARD_AMOUNT_INFO t1
														where    t1.AWARD_NUMBER =	AWARD_AMOUNT_INFO.AWARD_NUMBER	
														and t1.tnm_document_number in ( select s0.DOC_HDR_ID from KREW_DOC_HDR_T s0 
																						inner join TIME_AND_MONEY_DOCUMENT s1 on s0.DOC_HDR_ID = s1.DOCUMENT_NUMBER
																						where s1.AWARD_NUMBER = '022882-00001'
																						and s0.DOC_HDR_STAT_CD = 'F')
														)
		AND		TO_NUMBER(nvl(AWARD_AMOUNT_INFO.TRANSACTION_ID,0)) = ( SELECT MAX(TO_NUMBER(nvl(AMOUNT3.TRANSACTION_ID,0)))
																	FROM   AWARD_AMOUNT_INFO AMOUNT3
															WHERE  AMOUNT3.AWARD_NUMBER 	 = AWARD_AMOUNT_INFO.AWARD_NUMBER);
															 --AND    AWARD_AMOUNT_INFO.SEQUENCE_NUMBER  = AMOUNT3.SEQUENCE_NUMBER);
															 --AND TO_NUMBER(nvl(AMOUNT3.TRANSACTION_ID,0)) <= TO_NUMBER(nvl('399672',0)));



  		SELECT AWARD_AMOUNT_INFO.AWARD_AMOUNT_INFO_ID, AWARD_AMOUNT_INFO.SEQUENCE_NUMBER, 
		AWARD_AMOUNT_INFO.TRANSACTION_ID, AWARD_AMOUNT_INFO.OBLIGATION_EXPIRATION_DATE,
         AWARD_AMOUNT_INFO.ANTICIPATED_TOTAL_AMOUNT,
         AWARD_AMOUNT_INFO.AMOUNT_OBLIGATED_TO_DATE
FROM   AWARD_AMOUNT_INFO 
where AWARD_NUMBER = '022882-00001' and transaction_id = '399672';

  		SELECT AWARD_AMOUNT_INFO.SEQUENCE_NUMBER, AWARD_AMOUNT_INFO.TRANSACTION_ID, AWARD_AMOUNT_INFO.OBLIGATION_EXPIRATION_DATE,
         AWARD_AMOUNT_INFO.ANTICIPATED_TOTAL_AMOUNT,
         AWARD_AMOUNT_INFO.AMOUNT_OBLIGATED_TO_DATE
    	FROM AWARD_AMOUNT_INFO
		WHERE AWARD_AMOUNT_INFO.AWARD_NUMBER = '022882-00001' 
		AND     AWARD_AMOUNT_INFO.AWARD_AMOUNT_INFO_ID = ( select max(t1.AWARD_AMOUNT_INFO_ID) from AWARD_AMOUNT_INFO t1
														where    t1.AWARD_NUMBER =	AWARD_AMOUNT_INFO.AWARD_NUMBER	
														and t1.tnm_document_number in ( select s0.DOC_HDR_ID from KREW_DOC_HDR_T s0 
																						inner join TIME_AND_MONEY_DOCUMENT s1 on s0.DOC_HDR_ID = s1.DOCUMENT_NUMBER
																						where s1.AWARD_NUMBER = '022882-00001'
																						and s0.DOC_HDR_STAT_CD = 'F')
														)


	SELECT count(s0.DOC_HDR_ID) from KREW_DOC_HDR_T s0 
	inner join TIME_AND_MONEY_DOCUMENT s1 on s0.DOC_HDR_ID = s1.DOCUMENT_NUMBER
	where s1.AWARD_NUMBER = '022882-00001'
	and s0.DOC_HDR_STAT_CD = 'F';

select * from TIME_AND_MONEY_DOCUMENT s1
	where s1.AWARD_NUMBER = '022882-00001';

select * from AWARD_AMOUNT_INFO s1
	where s1.AWARD_NUMBER = '022882-00001';
	
  		SELECT AWARD_AMOUNT_INFO.OBLIGATION_EXPIRATION_DATE,
         AWARD_AMOUNT_INFO.ANTICIPATED_TOTAL_AMOUNT,
         AWARD_AMOUNT_INFO.AMOUNT_OBLIGATED_TO_DATE
    	FROM AWARD_AMOUNT_INFO
		WHERE AWARD_AMOUNT_INFO.AWARD_NUMBER = '022882-00001' 
		AND     AWARD_AMOUNT_INFO.AWARD_AMOUNT_INFO_ID = ( select max(t1.AWARD_AMOUNT_INFO_ID) from AWARD_AMOUNT_INFO t1
														where    t1.AWARD_NUMBER =	AWARD_AMOUNT_INFO.AWARD_NUMBER	
														and t1.tnm_document_number in ( select s0.DOC_HDR_ID from KREW_DOC_HDR_T s0 
																						inner join TIME_AND_MONEY_DOCUMENT s1 on s0.DOC_HDR_ID = s1.DOCUMENT_NUMBER
																						where s1.AWARD_NUMBER = '022882-00001'
																						and s0.DOC_HDR_STAT_CD = 'F')
														)
		AND		TO_NUMBER(nvl(AWARD_AMOUNT_INFO.TRANSACTION_ID,0)) = ( SELECT MAX(TO_NUMBER(nvl(AMOUNT3.TRANSACTION_ID,0)))
																	FROM   AWARD_AMOUNT_INFO AMOUNT3
															WHERE  AMOUNT3.AWARD_NUMBER 	 = AWARD_AMOUNT_INFO.AWARD_NUMBER
															 AND    AWARD_AMOUNT_INFO.SEQUENCE_NUMBER  = AMOUNT3.SEQUENCE_NUMBER
															 AND TO_NUMBER(nvl(AMOUNT3.TRANSACTION_ID,0)) <= TO_NUMBER(nvl('399672',0)));


--399672
								   
select sequence_number, award_amount_info_id, transaction_id from AWARD_AMOUNT_INFO s1
	where s1.AWARD_NUMBER = '022882-00001'
	order by award_amount_info_id;
								   