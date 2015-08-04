create or replace function fn_sync_award_disclosure(as_award in OSP$AWARD.MIT_AWARD_NUMBER@COEUS.KUALI%TYPE ,
	as_proposal in OSP$proposal.proposal_NUMBER@COEUS.KUALI%TYPE,
	as_user_id in OSP$USER.USER_ID@COEUS.KUALI%type)

return number is

li_rc 		number;
ls_person_id osp$person.person_id@COEUS.KUALI%type;
li_count NUMBER;
li_max_seq NUMBER;
li_event_typ_cd NUMBER := 1 ; --Award
li_awd_module_cd NUMBER := 1;
li_apprvd_seq NUMBER;

ls_perDisclNumber   OSP$COI_DISCLOSURE.COI_DISCLOSURE_NUMBER@COEUS.KUALI%type;
li_DisclSequence    OSP$COI_DISCLOSURE.SEQUENCE_NUMBER@COEUS.KUALI%type;
li_CurrentDisclSeq  OSP$COI_DISCLOSURE.SEQUENCE_NUMBER@COEUS.KUALI%type;
li_DispositionCode  OSP$COI_DISCLOSURE.DISCLOSURE_DISPOSITION_CODE@COEUS.KUALI%type;
li_ReviewStatusCode  OSP$COI_DISCLOSURE.REVIEW_STATUS_CODE@COEUS.KUALI%type;
li_EventType OSP$COI_DISCLOSURE.EVENT_TYPE_CODE@COEUS.KUALI%type;
li_AwardSequence    osp$award.sequence_number@COEUS.KUALI%type;
li_DisclMaxSeq  OSP$COI_DISCLOSURE.SEQUENCE_NUMBER@COEUS.KUALI%type;


CURSOR C_P_DISC_PERSON IS
    select  D.COI_DISCLOSURE_NUMBER, D.SEQUENCE_NUMBER,  D.PERSON_ID, D.DISCLOSURE_DISPOSITION_CODE, D.REVIEW_STATUS_CODE, D.EVENT_TYPE_CODE
     from osp$coi_disclosure@COEUS.KUALI d,
        (select distinct DD.COI_DISCLOSURE_NUMBER, DD.SEQUENCE_NUMBER
         from   osp$coi_disc_details@COEUS.KUALI dd
         where  dd.MODULE_CODE in (2, 3)
         and    dd.MODULE_ITEM_KEY = as_proposal
         and    DD.SEQUENCE_NUMBER = (select max(DD2.SEQUENCE_NUMBER)
                                     from   osp$coi_disc_details@COEUS.KUALI dd2
                                     where  DD.COI_DISCLOSURE_NUMBER = DD2.COI_DISCLOSURE_NUMBER
                                     and    DD.MODULE_ITEM_KEY = DD2.MODULE_ITEM_KEY)) discl
         where D.COI_DISCLOSURE_NUMBER = discl.COI_DISCLOSURE_NUMBER
         and   D.SEQUENCE_NUMBER = discl.SEQUENCE_NUMBER;



BEGIN
  li_rc:= 0;
  li_apprvd_seq:= -1;

  --Get Awards Current Sequence
  begin
        select max(sequence_number)
        into li_AwardSequence
        from osp$award@COEUS.KUALI
        where mit_award_number = as_award;
  exception
    when others then
        li_AwardSequence := 1;
  end;

  open C_P_DISC_PERSON;
  loop
        FETCH C_P_DISC_PERSON INTO ls_perDisclNumber, li_DisclSequence, ls_person_id, li_DispositionCode, li_ReviewStatusCode, li_EventType;
        EXIT WHEN C_P_DISC_PERSON%NOTFOUND;

        select max(SEQUENCE_NUMBER)
        into li_DisclMaxSeq
        from osp$coi_disclosure@COEUS.KUALI
        where COI_DISCLOSURE_NUMBER = ls_perDisclNumber;

        --**************************************************************************
        --  Check if an award from this awards hierarchy is included in the 'Current'
        -- disclosure for this peron
        --**************************************************************************
        li_Count := 0;

        select  count (D.COI_DISCLOSURE_NUMBER)
        into li_Count
         from osp$coi_disclosure@COEUS.KUALI d, osp$coi_disc_details@COEUS.KUALI dd
         where D.PERSON_ID = ls_person_id
         and D.DISCLOSURE_DISPOSITION_CODE = 1
         and D.SEQUENCE_NUMBER = (select max(d2.sequence_number)
            from osp$coi_disclosure@COEUS.KUALI d2
            where D.COI_DISCLOSURE_NUMBER = D2.COI_DISCLOSURE_NUMBER
            and D.DISCLOSURE_DISPOSITION_CODE = D2.DISCLOSURE_DISPOSITION_CODE)
         and D.COI_DISCLOSURE_NUMBER = DD.COI_DISCLOSURE_NUMBER
         and D.SEQUENCE_NUMBER = DD.SEQUENCE_NUMBER
         and substr(dd.MODULE_ITEM_KEY, 1,6)  = substr(as_award, 1, 6);

        if li_Count = 0 then
        --**************************************************************************
        --  A disclosure for this award does not exist in current disclosure
        -- Now check if an award disclosure exist in any pending disclosure submissions
        -- after current
        --**************************************************************************

        --Get sequence of 'Current' disclosure
            begin

            select  D.SEQUENCE_NUMBER
            into li_CurrentDisclSeq
             from osp$coi_disclosure@COEUS.KUALI d
             where D.PERSON_ID = ls_person_id
             and D.DISCLOSURE_DISPOSITION_CODE = 1
             and D.SEQUENCE_NUMBER = (select max(d2.sequence_number)
                from osp$coi_disclosure@COEUS.KUALI d2
                where D.COI_DISCLOSURE_NUMBER = D2.COI_DISCLOSURE_NUMBER
                and D.DISCLOSURE_DISPOSITION_CODE = D2.DISCLOSURE_DISPOSITION_CODE);

            exception
                when others then
                    li_CurrentDisclSeq := 0;
            end;

            select  count (D.COI_DISCLOSURE_NUMBER)
            into li_Count
             from osp$coi_disclosure@COEUS.KUALI d, osp$coi_disc_details@COEUS.KUALI dd
             where D.PERSON_ID = ls_person_id
             and D.SEQUENCE_NUMBER > li_CurrentDisclSeq
             and D.COI_DISCLOSURE_NUMBER = DD.COI_DISCLOSURE_NUMBER
             and D.SEQUENCE_NUMBER = DD.SEQUENCE_NUMBER
             and substr(dd.MODULE_ITEM_KEY, 1,6)  = substr(as_award, 1, 6);

        end if;

        if li_Count = 0 then
        --**************************************************************************
        --  There are no disclosure for any of the awards in this hierarchy for this person
        --  Copy proposal disclosure over to award
        --**************************************************************************

           if li_ReviewStatusCode = 1 then

            --***********************************************************
            --  PI Has not submitted the discloure.
            -- in this case we can replace the proposal disclosure with award

          /* Commented for COEUS-447 : When award is created, if the funding proposal has a disclosure that
                                       is in status Submitted for review, DO NOTHING.
             S T A R T S
                      update osp$coi_disc_details dd
                      set dd.MODULE_ITEM_KEY = as_award,
                          dd.MODULE_CODE = 1
                      where dd.COI_DISCLOSURE_NUMBER = ls_perDisclNumber
                          and dd.SEQUENCE_NUMBER = li_DisclSequence
                          and dd.MODULE_ITEM_KEY = as_proposal;


                      --IF event type is 'Proposal'
                      --Switch it to a proposal event disclosure
                      IF li_EventType = 2 then
                          update osp$coi_disclosure
                          set MODULE_ITEM_KEY = as_award,
                              EVENT_TYPE_CODE  = 1
                          where COI_DISCLOSURE_NUMBER = ls_perDisclNumber
                          and SEQUENCE_NUMBER = li_DisclSequence;
                      end if;
            E N D S
          */
                 return li_rc;

           else  -- Already Submitted

            --This disclosure is already submitted by the PI and is under review
            -- In this case, leave the proposal in the disclosure and insert rows for the new award.

            IF (li_EventType = 2) AND (li_DispositionCode <> 1) then
                --This is  proposal event disclousure that COI admin has not yet approved.
                --Mark this superseded by award and create a new disclosure sequence for award

              /* Commented for COEUS-447 : When award is created, if the funding proposal has a disclosure that
                                             is in status Submitted for review, DO NOTHING.
                      S T A R T S
                              insert into osp$coi_disclosure(
                              COI_DISCLOSURE_NUMBER,
                              SEQUENCE_NUMBER,
                              PERSON_ID,
                              CERTIFICATION_TEXT,
                              CERTIFIED_BY,
                              CERTIFICATION_TIMESTAMP,
                              DISCLOSURE_DISPOSITION_CODE,
                              DISCLOSURE_STATUS_CODE,
                              EXPIRATION_DATE,
                              UPDATE_TIMESTAMP,
                              UPDATE_USER,
                              EVENT_TYPE_CODE,
                              REVIEW_STATUS_CODE,
                              MODULE_ITEM_KEY,
                              CREATE_TIMESTAMP,
                              CREATE_USER)
                              select COI_DISCLOSURE_NUMBER,
                                  li_DisclMaxSeq + 1,
                                  PERSON_ID, CERTIFICATION_TEXT, CERTIFIED_BY,CERTIFICATION_TIMESTAMP,
                                  DISCLOSURE_DISPOSITION_CODE, DISCLOSURE_STATUS_CODE, EXPIRATION_DATE,
                                  UPDATE_TIMESTAMP, UPDATE_USER, 1,
                                  REVIEW_STATUS_CODE,
                                  as_award,sysdate,as_user_id
                              from osp$coi_disclosure d
                              where d.COI_DISCLOSURE_NUMBER = ls_perDisclNumber
                                  and D.SEQUENCE_NUMBER = li_DisclSequence;

                              insert into osp$coi_disc_details
                                 select dd.COI_DISCLOSURE_NUMBER,
                                  li_DisclMaxSeq + 1,
                                  SEQ_DISCLOSURE_DETAIL_ID.nextval,
                                  1,
                                  as_award,
                                  dd.ENTITY_NUMBER,
                                  dd.ENTITY_SEQUENCE_NUMBER,
                                  DD.COI_PROJECT_STATUS_CODE,
                                  dd.RELATIONSHIP_DESCRIPTION,
                                  dd.UPDATE_TIMESTAMP,
                                  dd.UPDATE_USER,
                                  dd.ORG_RELATION_DESCRIPTION
                                 from osp$coi_disc_details dd
                                 where dd.COI_DISCLOSURE_NUMBER = ls_perDisclNumber
                                  and dd.SEQUENCE_NUMBER = li_DisclSequence;


                              update osp$coi_disclosure
                              set DISCLOSURE_STATUS_CODE = 201
                              where COI_DISCLOSURE_NUMBER = ls_perDisclNumber
                                  and SEQUENCE_NUMBER = li_DisclSequence;

                              insert into osp$coi_disc_details
                                 select dd.COI_DISCLOSURE_NUMBER,
                                  dd.SEQUENCE_NUMBER,
                                  SEQ_DISCLOSURE_DETAIL_ID.nextval,
                                  DD.MODULE_CODE,
                                  dd.MODULE_ITEM_KEY,
                                  dd.ENTITY_NUMBER,
                                  dd.ENTITY_SEQUENCE_NUMBER,
                                  201, --Superseded by Award
                                  dd.RELATIONSHIP_DESCRIPTION,
                                  dd.UPDATE_TIMESTAMP,
                                  dd.UPDATE_USER,
                                  dd.ORG_RELATION_DESCRIPTION
                                 from osp$coi_disc_details dd
                                 where dd.COI_DISCLOSURE_NUMBER = ls_perDisclNumber
                                  and dd.SEQUENCE_NUMBER = li_DisclSequence
                                  and dd.MODULE_ITEM_KEY = as_proposal
                                  and DD.COI_DISC_DETAILS_NUMBER = (select max(dd2.COI_DISC_DETAILS_NUMBER)
                                          from osp$coi_disc_details dd2
                                          where DD.COI_DISCLOSURE_NUMBER = DD2.COI_DISCLOSURE_NUMBER
                                          and DD.SEQUENCE_NUMBER = DD2.SEQUENCE_NUMBER
                                          and DD.MODULE_ITEM_KEY = DD2.MODULE_ITEM_KEY
                                              and DD.ENTITY_NUMBER = DD2.ENTITY_NUMBER)
                                  and DD.COI_PROJECT_STATUS_CODE <> 201;
                   E N D S
               */
                          return li_rc;

            else
               --This disclosure is a Renewal or Annual
               --OR its an approved current disclosure.

               --Insert rows for award disclosure - Copy of proposal rows.
               insert into osp$coi_disc_details@COEUS.KUALI
               select dd.COI_DISCLOSURE_NUMBER,
                dd.SEQUENCE_NUMBER,
                SEQ_DISCLOSURE_DETAIL_ID.nextval@COEUS.KUALI,
                1,
                as_award,
                dd.ENTITY_NUMBER,
                dd.ENTITY_SEQUENCE_NUMBER,
                dd.COI_PROJECT_STATUS_CODE,
                dd.RELATIONSHIP_DESCRIPTION,
                dd.UPDATE_TIMESTAMP,
                dd.UPDATE_USER,
                dd.ORG_RELATION_DESCRIPTION
               from osp$coi_disc_details@COEUS.KUALI dd
               where dd.COI_DISCLOSURE_NUMBER = ls_perDisclNumber
                and dd.SEQUENCE_NUMBER = li_DisclSequence
                and dd.MODULE_ITEM_KEY = as_proposal
                and DD.COI_DISC_DETAILS_NUMBER = (select max(dd2.COI_DISC_DETAILS_NUMBER)
                        from osp$coi_disc_details@COEUS.KUALI dd2
                        where DD.COI_DISCLOSURE_NUMBER = DD2.COI_DISCLOSURE_NUMBER
                        and DD.SEQUENCE_NUMBER = DD2.SEQUENCE_NUMBER
                        and DD.MODULE_ITEM_KEY = DD2.MODULE_ITEM_KEY
                        and DD.ENTITY_NUMBER = DD2.ENTITY_NUMBER
                        and DD2.COI_PROJECT_STATUS_CODE <> 201);
              --**************************************************************************
              --  Insert rows to mark Proposal discl status as Superseded by Award
              --  need to do it only if the latest status for proposal is not superseded by award.
              --**************************************************************************

               insert into osp$coi_disc_details@COEUS.KUALI
               select dd.COI_DISCLOSURE_NUMBER,
                dd.SEQUENCE_NUMBER,
                SEQ_DISCLOSURE_DETAIL_ID.nextval@COEUS.KUALI,
                DD.MODULE_CODE,
                dd.MODULE_ITEM_KEY,
                dd.ENTITY_NUMBER,
                dd.ENTITY_SEQUENCE_NUMBER,
                201, --Superseded by Award
                dd.RELATIONSHIP_DESCRIPTION,
                dd.UPDATE_TIMESTAMP,
                dd.UPDATE_USER,
                dd.ORG_RELATION_DESCRIPTION
               from osp$coi_disc_details@COEUS.KUALI dd
               where dd.COI_DISCLOSURE_NUMBER = ls_perDisclNumber
                and dd.SEQUENCE_NUMBER = li_DisclSequence
                and dd.MODULE_ITEM_KEY = as_proposal
                and DD.COI_DISC_DETAILS_NUMBER = (select max(dd2.COI_DISC_DETAILS_NUMBER)
                        from osp$coi_disc_details@COEUS.KUALI dd2
                        where DD.COI_DISCLOSURE_NUMBER = DD2.COI_DISCLOSURE_NUMBER
                        and DD.SEQUENCE_NUMBER = DD2.SEQUENCE_NUMBER
                        and DD.MODULE_ITEM_KEY = DD2.MODULE_ITEM_KEY
                            and DD.ENTITY_NUMBER = DD2.ENTITY_NUMBER)
                and DD.COI_PROJECT_STATUS_CODE <> 201;

            end if;

           end if;


--        else
            --Need to figure out ehat should be done here, a disclosure already exists for the person in this award hierarchy
        end if;


  end loop;

  return li_rc;
END;
/