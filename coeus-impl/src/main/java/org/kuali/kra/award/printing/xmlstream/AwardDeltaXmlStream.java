/*
 * Copyright 2005-2014 The Kuali Foundation
 * 
 * Licensed under the GNU Affero General Public License, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.opensource.org/licenses/ecl1.php
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.kuali.kra.award.printing.xmlstream;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.xmlbeans.XmlObject;
import org.kuali.coeus.common.framework.custom.attr.CustomAttribute;
import org.kuali.coeus.common.framework.sponsor.Sponsor;
import org.kuali.coeus.common.framework.person.attr.PersonTraining;
import org.kuali.coeus.common.framework.version.history.VersionHistory;
import org.kuali.coeus.common.framework.version.history.VersionHistoryService;
import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.award.contacts.AwardPerson;
import org.kuali.kra.award.customdata.AwardCustomData;
import org.kuali.kra.award.document.AwardDocument;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.home.AwardAmountInfo;
import org.kuali.kra.award.home.AwardTransferringSponsor;
import org.kuali.kra.award.paymentreports.paymentschedule.AwardPaymentSchedule;
import org.kuali.kra.award.printing.AwardPrintParameters;
import org.kuali.kra.award.printing.AwardPrintType;
import org.kuali.kra.printing.schema.AwardNoticeDocument;
import org.kuali.kra.printing.schema.AwardNoticeDocument.AwardNotice.PrintRequirement;
import org.kuali.kra.printing.schema.AwardType;
import org.kuali.kra.printing.schema.AwardType.AwardOtherDatas;
import org.kuali.kra.printing.schema.AwardType.AwardOtherDatas.OtherData;
import org.kuali.kra.printing.schema.AwardType.AwardPaymentSchedules;
import org.kuali.kra.printing.schema.AwardType.AwardPaymentSchedules.PaymentSchedule;
import org.kuali.kra.printing.schema.AwardType.AwardSpecialReviews;
import org.kuali.kra.printing.schema.AwardType.AwardTransferringSponsors;
import org.kuali.kra.printing.schema.AwardType.AwardTransferringSponsors.TransferringSponsor;
import org.kuali.kra.printing.schema.AwardDisclosureType;
import org.kuali.kra.printing.schema.AwardHeaderType;
import org.kuali.kra.printing.schema.AwardValidationType;
import org.kuali.kra.printing.schema.DisclosureItemType;
import org.kuali.kra.printing.schema.OtherGroupDetailsType;
import org.kuali.kra.printing.schema.OtherGroupType;
import org.kuali.kra.printing.schema.SpecialReviewType;
import org.kuali.kra.award.specialreview.AwardSpecialReview;
import org.kuali.kra.timeandmoney.document.TimeAndMoneyDocument;
import org.kuali.kra.timeandmoney.service.TimeAndMoneyActionSummaryService;
import org.kuali.kra.timeandmoney.transactions.AwardAmountTransaction;
import org.kuali.rice.core.api.CoreApiServiceLocator;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.core.api.datetime.DateTimeService;
import org.kuali.rice.krad.util.GlobalVariables;

import edu.mit.kc.award.service.AwardCommonValidationService;
import edu.mit.kc.infrastructure.KcMitConstants;

/**
 * This class generates XML that conforms with the XSD related to Award Delta
 * Report. The data for XML is derived from {@link ResearchDocumentBase} and
 * {@link Map} of details passed to the class.
 * 
 * @author
 * 
 */
public class AwardDeltaXmlStream extends AwardBaseStream {

	private static final String SEQUENCE_NUMBER = "sequenceNumber";
	private VersionHistoryService versionHistoryService;
	private TimeAndMoneyActionSummaryService actionSummaryService;
	
	private ConfigurationService kualiConfigurationService;


	/**
	 * This method generates XML for Award Delta Report. It uses data passed in
	 * {@link ResearchDocumentBase} for populating the XML nodes. The XMl once
	 * generated is returned as {@link XmlObject}
	 * 
	 * @param printableBusinessObject
	 *            using which XML is generated
	 * @param reportParameters
	 *            parameters related to XML generation
	 * @return {@link XmlObject} representing the XML
	 */
	public Map<String, XmlObject> generateXmlStream(
			KcPersistableBusinessObjectBase printableBusinessObject, Map<String, Object> reportParameters) {
		Map<String, XmlObject> xmlObjectList = new LinkedHashMap<String, XmlObject>();
		AwardNoticeDocument awardNoticeDocument = AwardNoticeDocument.Factory
				.newInstance();
		initialize((Award) printableBusinessObject, reportParameters);
		if (award != null) {
			awardNoticeDocument.setAwardNotice(getAwardNotice(reportParameters));
		}
		xmlObjectList.put(
				AwardPrintType.AWARD_DELTA_REPORT.getAwardPrintType(),awardNoticeDocument);
		return xmlObjectList;
	}

	/*
	 * This method initializes the awardDocument ,award , and ,awardAmountInfo
	 * reference variables.
	 */
	private void initialize(Award award1,
			Map<String, Object> reportParameters) {
		this.awardDocument = award1.getAwardDocument();
		this.award = award1;
		String awardNumber = getAwardNumberFromAward(awardDocument);
		if (awardNumber != null) {
			List<VersionHistory> awardSequenceHistoryList = versionHistoryService.loadVersionHistory(Award.class, awardNumber);
			int sequenceNumber = 0;
			int prevSequenceNumber = 0;
			Long transactionId = new Long(0);
			long prevTransactionId = 0;
			if (reportParameters.get(SEQUENCE_NUMBER) != null) {
				sequenceNumber = (Integer) reportParameters.get(SEQUENCE_NUMBER);
				award = getAwardForSeqenceNumber(awardNumber, sequenceNumber);
			}
			if (reportParameters.get(AwardPrintParameters.TRANSACTION_ID_INDEX.getAwardPrintParameter()) != null) {
				int transactionIdx = (Integer) reportParameters.get(AwardPrintParameters.TRANSACTION_ID_INDEX.getAwardPrintParameter());
				if (award != null) {
					awardAmountInfo = award.getAwardAmountInfos().get(transactionIdx); 
					transactionId = awardAmountInfo.getTransactionId();
				}
			}
			boolean sequenceNumberFound = false;
			for (VersionHistory versionHistory : awardSequenceHistoryList) {
				if (sequenceNumber == versionHistory.getSequenceOwnerSequenceNumber()) {
					sequenceNumberFound = true;
				}
				if (sequenceNumberFound) {
					prevSequenceNumber = sequenceNumber-1;
					break;
				}
			}
			if (sequenceNumber != 0) {
				award = getAwardForSeqenceNumber(awardNumber, sequenceNumber);
			}
			List<AwardAmountTransaction> awardAmountTransactions = getAwardAmountTransactions(awardNumber);
			boolean transactionIdFound = false;
			for (AwardAmountTransaction timeAndMoneyActionSummary : awardAmountTransactions) {
				if (transactionId != null && transactionId.equals(timeAndMoneyActionSummary.getAwardAmountTransactionId())) {
					transactionIdFound = true;
				}
				if (transactionIdFound) {
					prevTransactionId = transactionId-1;//timeAndMoneyActionSummary.getAwardAmountTransactionId();
					break;
				}
			}
			if(prevSequenceNumber!=0){
			    initializePrevAward(awardNumber, prevSequenceNumber,prevTransactionId);
			}
		}
	}

	/*
	 * This method will return the award amount transaction list from
	 * timeAndMoney document,which matches award number given.
	 */
	private List<AwardAmountTransaction> getAwardAmountTransactions(
			String awardNumber) {
		List<AwardAmountTransaction> awardAmountTransactions = new ArrayList<AwardAmountTransaction>();
		Map<String, String> timeAndMoneyMap = new HashMap<String, String>();
		timeAndMoneyMap.put(ROOT_AWARD_NUMBER_PARAMETER, awardNumber);
		List<TimeAndMoneyDocument> timeAndMoneyList = (List<TimeAndMoneyDocument>) businessObjectService
				.findMatching(TimeAndMoneyDocument.class, timeAndMoneyMap);
		if (timeAndMoneyList != null && !timeAndMoneyList.isEmpty()) {
			TimeAndMoneyDocument timeAndMoneyDocument = timeAndMoneyList.get(0);
			awardAmountTransactions = timeAndMoneyDocument
					.getAwardAmountTransactions();
		}
		return awardAmountTransactions;
	}

	/*
	 * This method will get the Award Number from Award Document
	 */
	private String getAwardNumberFromAward(AwardDocument awardDocument) {
		String awardNumber = null;
		if (awardDocument != null && awardDocument.getAward() != null
				&& awardDocument.getAward().getAwardNumber() != null) {
			awardNumber = awardDocument.getAward().getAwardNumber();
		}
		return awardNumber;
	}

	/*
	 * This method initializes the prevAward and prevAwardAmountInfo reference
	 * variables.
	 */
	private void initializePrevAward(String awardNumber, long sequenceNumber,long transactionId) {
		if (transactionId > 1) {
			prevAward = award;
			if (award != null) {
				prevAwardAmountInfo = getPrevAwardAmountInfo(award,transactionId);
			}
		} else {
			prevAward = getAwardForSeqenceNumber(awardNumber, sequenceNumber);
			if (prevAward != null) {
				List<AwardAmountInfo> awardAmountInfos = prevAward.getAwardAmountInfos();
				if (awardAmountInfos != null && !awardAmountInfos.isEmpty()) {
					prevAwardAmountInfo = awardAmountInfos.get(awardAmountInfos.size() - 1);
				}
			}
		}
	}

	/*
	 * This method will get the awardAmountInfo for given transaction id
	 */
	private AwardAmountInfo getPrevAwardAmountInfo(Award award,
			long transactionId) {
		org.kuali.kra.award.home.AwardAmountInfo awardAmountInfo = null;
		for (AwardAmountInfo awardAmount : award.getAwardAmountInfos()) {
			if (awardAmount.getTransactionId()!=null && awardAmount.getTransactionId().longValue() == transactionId) {
				awardAmountInfo = awardAmount;
				break;
			}
		}
		return awardAmountInfo;
	}

	/*
	 * This method will get the awardForSeqenceNumber
	 */
	private Award getAwardForSeqenceNumber(String awardNumber,
			long sequenceNumber) {
		Award awardForSeqenceNumber = null;
		Map<String, String> awardMap = new HashMap<String, String>();
		awardMap.put(AWARD_NUMBER_PARAMETER, awardNumber);
		awardMap.put(SEQUENCE_NUMBER_PARAMETER, String.valueOf(sequenceNumber));
		List<Award> awardList = (List<Award>) businessObjectService
				.findMatching(Award.class, awardMap);
		if (awardList != null && !awardList.isEmpty()) {
			awardForSeqenceNumber = awardList.get(0);
		}
		return awardForSeqenceNumber;
	}

	/*
	 * This method will set the values to award attributes and finally returns
	 * award Xml object
	 */
	protected AwardType getAward() {
		AwardType awardType = super.getAward();
		awardType.setAwardTransferringSponsors(getAwardTransferringSponsors());
		awardType.setAwardPaymentSchedules(getAwardPaymentSchedules());
		awardType.setAwardSpecialReviews(getAwardSpecialReviews());
		awardType.setAwardOtherDatas(getAwardOtherDatas());
		return awardType;
	}

	/*
	 * This method will set the values to AwardSpecialReviews attributes and
	 * finally returns AwardSpecialReviews Xml object
	 */
	private AwardSpecialReviews getAwardSpecialReviews() {
		AwardSpecialReviews awardSpecialReviews = AwardSpecialReviews.Factory
				.newInstance();
		String specialReviewIndicator = award.getSpecialReviewIndicator();
		List<SpecialReviewType> specialReviewTypesList = new LinkedList<SpecialReviewType>();
	if (specialReviewIndicator != null
				&& !specialReviewIndicator.equals(EMPTY_STRING)) {
			specialReviewIndicator = specialReviewIndicator.length() == 1 ? specialReviewIndicator
					: specialReviewIndicator.substring(1, 2);
			if (specialReviewIndicator.equals(INDICATOR_CONSTANT)) {
				List<AwardSpecialReview> specialReviewList = award
						.getSpecialReviews();
				SpecialReviewType specialReviewType = null;
				for (AwardSpecialReview awardSpecialReview : specialReviewList) {
					specialReviewType = getAwardSpecialReview(awardSpecialReview);
					specialReviewTypesList.add(specialReviewType);
				}
			}
		}
		awardSpecialReviews.setSpecialReviewArray(specialReviewTypesList
				.toArray(new SpecialReviewType[0]));
		return awardSpecialReviews;
	}

	/*
	 * This method will set the values to AwardPaymentSchedules attributes and
	 * finally returns AwardPaymentSchedules Xml object
	 */
	private AwardPaymentSchedules getAwardPaymentSchedules() {
		AwardPaymentSchedules awardPaymentSchedules = AwardPaymentSchedules.Factory
				.newInstance();
		String paymentScheduleIndicator = award.getPaymentScheduleIndicator();
		List<PaymentSchedule> paymentSchedulesList = new LinkedList<PaymentSchedule>();
		/*if (paymentScheduleIndicator != null
				&& !paymentScheduleIndicator.equals(EMPTY_STRING)) {*/
			paymentScheduleIndicator = paymentScheduleIndicator.length() == 1 ? paymentScheduleIndicator
					: paymentScheduleIndicator.substring(1, 2);
		/*	if (paymentScheduleIndicator.equals(INDICATOR_CONSTANT)) {*/
	List<AwardPaymentSchedule> paymentScheduleItems = award
						.getPaymentScheduleItems();
				PaymentSchedule paymentSchedule = null;
				for (AwardPaymentSchedule awardPaymentSchedule : paymentScheduleItems) {
					paymentSchedule = getAwardPaymentSchedule(awardPaymentSchedule);
					paymentSchedulesList.add(paymentSchedule);
				//}
			//}
		}
		awardPaymentSchedules.setPaymentScheduleArray(paymentSchedulesList
				.toArray(new PaymentSchedule[0]));
		return awardPaymentSchedules;
	}

	/*
	 * This method will set the values to AwardTransferringSponsors attributes
	 * and finally returns AwardTransferringSponsors Xml object
	 */
	private AwardTransferringSponsors getAwardTransferringSponsors() {
		AwardTransferringSponsors transferringSponsors = AwardTransferringSponsors.Factory.newInstance();
		List<TransferringSponsor> transferringSponsorList = new LinkedList<TransferringSponsor>();
		List<AwardTransferringSponsor> awardTransferringSponsorList = award.getAwardTransferringSponsors();
        List<AwardTransferringSponsor> prevTransferringSponsorList = prevAward == null?new ArrayList<AwardTransferringSponsor>():
                                                                        prevAward.getAwardTransferringSponsors();
		TransferringSponsor transferringSponsor = null;
		for (AwardTransferringSponsor awardTransferringSponsor : awardTransferringSponsorList) {
		    if(checkSponsorCodeChange(awardTransferringSponsor, prevTransferringSponsorList)){
		        transferringSponsor = getAwardTransferringSponsor(awardTransferringSponsor);
		    }else{
		        transferringSponsor = getAwardTransferringSponsor(awardTransferringSponsor,SPONSOR_CODE_ADDED_INDICATOR);
		    }
            transferringSponsorList.add(transferringSponsor);
		}
		for (AwardTransferringSponsor awardTransferringSponsor : prevTransferringSponsorList) {
            if(!checkSponsorCodeChange(awardTransferringSponsor, awardTransferringSponsorList)){
                transferringSponsor = getAwardTransferringSponsor(awardTransferringSponsor,SPONSOR_CODE_DELETED_INDICATOR);
                transferringSponsorList.add(transferringSponsor);
            }
		}
		transferringSponsors.setTransferringSponsorArray(transferringSponsorList.toArray(new TransferringSponsor[0]));
		return transferringSponsors;
	}
//    private AwardTransferringSponsors getAwardTransferringSponsors() {
//        AwardTransferringSponsors transferringSponsors = AwardTransferringSponsors.Factory
//                .newInstance();
//        List<TransferringSponsor> transferringSponsorList = new LinkedList<TransferringSponsor>();
//        String transferSponsorIndicator = award.getTransferSponsorIndicator();
//        if (transferSponsorIndicator != null
//                && !transferSponsorIndicator.equals(EMPTY_STRING)) {
//            transferSponsorIndicator = transferSponsorIndicator.length() == 1 ? transferSponsorIndicator
//                    : transferSponsorIndicator.substring(1, 2);
//            if (transferSponsorIndicator.equals(TRANSFERSPONSOR_MODIFIED_VALUE)) {
//                List<AwardTransferringSponsor> awardTransferringSponsorList = award
//                        .getAwardTransferringSponsors();
//                TransferringSponsor transferringSponsor = null;
//                for (AwardTransferringSponsor awardTransferringSponsor : awardTransferringSponsorList) {
//                    transferringSponsor = getAwardTransferringSponsor(awardTransferringSponsor);
//                    transferringSponsorList.add(transferringSponsor);
//                }
//                List<AwardTransferringSponsor> prevTransferringSponsorList = null;
//                if (prevAward != null) {
//                    prevTransferringSponsorList = prevAward
//                            .getAwardTransferringSponsors();
//                }
//                if (prevTransferringSponsorList != null) {
//                    for (AwardTransferringSponsor awardTransferringSponsor : prevTransferringSponsorList) {
//                        transferringSponsor = getPrevAwardTransferringSponsorBean(awardTransferringSponsor);
//                        transferringSponsorList.add(transferringSponsor);
//                    }
//                }
//            }
//        }
//        transferringSponsors
//                .setTransferringSponsorArray(transferringSponsorList
//                        .toArray(new TransferringSponsor[0]));
//        return transferringSponsors;
//    }

    /**
     * This method...
     * @param awardTransferringSponsor
     * @param awardTransferringSponsors
     */
    private boolean checkSponsorCodeChange(AwardTransferringSponsor awardTransferringSponsor,
            List<AwardTransferringSponsor> awardTransferringSponsors) {
        for (AwardTransferringSponsor currentAwardTransferringSponsor : awardTransferringSponsors) {
            if( awardTransferringSponsor.getSponsorCode().equals(currentAwardTransferringSponsor.getSponsorCode())){
                return true;
            }
        }
        return false;
    }

    /**
     * <p>
     * This method will set the values to transferring sponsor XmlObject and
     * return it
     * </p>
     * 
     * @param awardTransferringSponsor
     *            it contains information about the award transferring sponsor
     *            {@link AwardTransferringSponsor}
     * @return awardTransferringSponsor xmlObject
     */
    protected TransferringSponsor getAwardTransferringSponsor(
            AwardTransferringSponsor awardTransferringSponsor, String prefix) {
        TransferringSponsor transferringSponsor = TransferringSponsor.Factory.newInstance();
        if (awardTransferringSponsor.getAwardNumber() != null) {
            transferringSponsor.setAwardNumber(awardTransferringSponsor
                    .getAwardNumber());
        }
        if (awardTransferringSponsor.getSequenceNumber() != null) {
            transferringSponsor.setSequenceNumber(awardTransferringSponsor
                    .getSequenceNumber());
        }
        transferringSponsor.setSponsorCode(prefix+awardTransferringSponsor.getSponsorCode());
        Sponsor sponsor = awardTransferringSponsor.getSponsor();
        if (sponsor != null && sponsor.getSponsorName() != null) {
            transferringSponsor.setSponsorDescription(sponsor.getSponsorName());
        }
        return transferringSponsor;
    }
    
    /*
	 * This method will set the values to AwardOtherDatas attributes and finally
	 * returns AwardOtherDatas Xml object
	 */	
	private AwardOtherDatas getAwardOtherDatas() {
		AwardOtherDatas awardOtherDatas = AwardOtherDatas.Factory.newInstance();
		List<AwardCustomData> awardCustomDataList = award
				.getAwardCustomDataList();
		List<OtherData> otherDatas = new ArrayList<OtherData>();
		OtherData otherData = null;
		int count =0;
		for (AwardCustomData awardCustomData : awardCustomDataList) {
			otherData = OtherData.Factory.newInstance();
			String columnValue = awardCustomData.getValue();
			if (awardCustomData.getCustomAttribute() != null
					&& awardCustomData.getCustomAttribute().getName() != null) {
				otherData.setColumnName(awardCustomData.getCustomAttribute()
						.getName());
			}
			if (columnValue != null) {
				if (prevAward != null && !prevAward.getAwardCustomDataList().isEmpty() &&prevAward.getAwardCustomDataList().size() > count -1 ) {
					for(AwardCustomData preAwardCustomData : prevAward.getAwardCustomDataList()){
						if(awardCustomData.getCustomAttributeId().equals(preAwardCustomData.getCustomAttributeId())){
							String prevColumValue = preAwardCustomData.getValue();
							columnValue = getModColumValue(columnValue,
									prevColumValue);
						}
					}
				} 
				otherData.setColumnValue(columnValue);
			}
			otherDatas.add(otherData);
			count++;
		}
		awardOtherDatas.setOtherDataArray(otherDatas.toArray(new OtherData[0]));
		return awardOtherDatas;
	}
	
	
	private String getModColumValue(String columnValue,
			String prevColumValue) {
		String columnValueMod = null;
		if (columnValue != null) {
			if (prevColumValue == null
					|| !columnValue.equals(prevColumValue)) {
				columnValueMod = new StringBuilder(START_ASTERISK_SPACE_INDICATOR).append(
						columnValue).toString();

			} else {
				columnValueMod = columnValue;
			}
		}
		return columnValueMod;
	}
	
	/*
	 * This method sets the values to print requirement attributes and finally
	 * returns the print requirement xml object
	 */
	protected PrintRequirement getPrintRequirement(
			Map<String, Object> reportParameters) {
		PrintRequirement printRequirement = PrintRequirement.Factory
				.newInstance();
		if (reportParameters != null) {
			printRequirement.setAddressListRequired(REQUIRED);
			printRequirement.setCloseoutRequired(REQUIRED);
			printRequirement.setCommentsRequired(REQUIRED);
			printRequirement.setCostSharingRequired(REQUIRED);
			printRequirement.setEquipmentRequired(REQUIRED);
			printRequirement.setFlowThruRequired(REQUIRED);
			printRequirement.setForeignTravelRequired(REQUIRED);
			printRequirement.setHierarchyInfoRequired(REQUIRED);
			printRequirement.setIndirectCostRequired(REQUIRED);
			printRequirement.setPaymentRequired(REQUIRED);
			printRequirement.setProposalDueRequired(REQUIRED);
			printRequirement.setSubcontractRequired(REQUIRED);
			printRequirement.setScienceCodeRequired(REQUIRED);
			printRequirement.setSpecialReviewRequired(REQUIRED);
			printRequirement.setTermsRequired(REQUIRED);
			printRequirement.setTechnicalReportingRequired(REQUIRED);
			printRequirement.setReportingRequired(REQUIRED);
			printRequirement.setCurrentDate(dateTimeService
					.getCurrentCalendar());
			printRequirement
					.setSignatureRequired(getSignatureRequired(reportParameters));
		}
		return printRequirement;
	}

	/*
	 * This method will get the signature required if input parameter signature
	 * required is true then 1 else 0
	 */
	private String getSignatureRequired(Map<String, Object> reportParameters) {
		String signatureRequired = null;
		if (reportParameters.get(SIGNATURE_REQUIRED) != null
				&& ((Boolean) reportParameters.get(SIGNATURE_REQUIRED))
						.booleanValue()) {
			signatureRequired = REQUIRED;
		} else {
			signatureRequired = NOT_REQUIRED;
		}
		return signatureRequired;
	}

	public VersionHistoryService getVersionHistoryService() {
		return versionHistoryService;
	}

	public void setVersionHistoryService(
			VersionHistoryService versionHistoryService) {
		this.versionHistoryService = versionHistoryService;
	}

	public TimeAndMoneyActionSummaryService getActionSummaryService() {
		return actionSummaryService;
	}

	public void setActionSummaryService(
			TimeAndMoneyActionSummaryService actionSummaryService) {
		this.actionSummaryService = actionSummaryService;
	}
	protected AwardDisclosureType getAwardDisclosureType() {
		AwardDisclosureType awardDisclosureType = AwardDisclosureType.Factory
				.newInstance();
		AwardHeaderType awardHeaderType = getAwardHeaderType();
		awardDisclosureType.setAwardHeader(awardHeaderType);
		DisclosureItemType[] disclosureItemTypes = getDisclosureItems(awardDisclosureType);
		awardDisclosureType.setDisclosureItemArray(disclosureItemTypes);
		awardDisclosureType.setAwardValidationArray(getAwardValidation());
		
		return awardDisclosureType;
	}

	
	/*
	 * This method will set the values to disclosure items and finally return
	 * disclosure XmlObject array
	 * 
	 */
	private DisclosureItemType[] getDisclosureItems(AwardDisclosureType awardDisclosureType) {
		List<DisclosureItemType> disclosureItems = new ArrayList<DisclosureItemType>();
		boolean isHoldPrompt = true;
		boolean isTrainingRequired = false;
		
		isHoldPrompt = KcServiceLocator.getService(AwardCommonValidationService.class).validateAwardOnCOI(award);
		isTrainingRequired = isTrainingRequired(award);
		if(!isHoldPrompt || isTrainingRequired){
			for (AwardPerson awardPerson : award.getProjectPersons()) {
				List<AwardPerson> awardPersons = KcServiceLocator.getService(AwardCommonValidationService.class).getCOIHoldPromptDisclousureItems(award, awardPerson);
				if(awardPersons!=null && !awardPersons.isEmpty()){
					for(AwardPerson person : awardPersons){
						DisclosureItemType disclosureItemType = DisclosureItemType.Factory
								.newInstance();
						disclosureItemType.setPersonName(person.getPerson().getFullName());
						disclosureItemType.setDisclosureNumber(person.getRole().getRoleDescription());
						if(person.isDisclosuerNotRequired()){
							disclosureItemType.setDisclosureTypeDesc("Disclosure Not Required");
						}else{
							String disclosureStatusDesc = KcServiceLocator.getService(AwardCommonValidationService.class).getAwardDisclousureStatusForPerson(award, person.getPerson().getPersonId());
							disclosureItemType.setDisclosureTypeDesc(disclosureStatusDesc);
						}
						if(person.isTrainingRequired()){
							disclosureItemType.setDisclosureStatusDesc(getTrainingStatus(person));
						}else{
							disclosureItemType.setDisclosureStatusDesc("Training Not Required");
						}
						disclosureItems.add(disclosureItemType);
						awardDisclosureType.setDisclosureValidation("1");
					}
				}
			}
		}
		return disclosureItems.toArray(new DisclosureItemType[0]);
	}
	
	private boolean isTrainingRequired(Award award){
		boolean trainingRequired =	KcServiceLocator.getService(AwardCommonValidationService.class).getTrainingRequired(award);
		if(trainingRequired){
			for(AwardPerson awardPerson : award.getProjectPersons()){
				if(awardPerson.getPersonId()!=null){
					if(!getTrainingStatus(awardPerson).equalsIgnoreCase("Training Completed")){
						trainingRequired = true;
						return trainingRequired;
					}else{
						trainingRequired = false;
					}
				}
			}
		}
		return trainingRequired;
	}
	
	private String getTrainingStatus(AwardPerson person){
		String training = "Training Required";
		Map<String, String> queryMap = new HashMap<String, String>();
		queryMap.put("trainingCode", "54");
		queryMap.put("personId",person.getPersonId());
		List <PersonTraining> personTrainingList = (List<PersonTraining>) getBusinessObjectService().findMatching(PersonTraining.class, queryMap);
		if(personTrainingList!=null && !personTrainingList.isEmpty()){
			PersonTraining personTraining = personTrainingList.get(0);
			if(personTraining.getFollowupDate()!=null && personTraining.getFollowupDate().after(KcServiceLocator.getService(DateTimeService.class).getCurrentDate())){
				training = "Training Completed";
			}
			else{
				training = "Training Required";
			}
		}
		return training;
	}
	
	private AwardValidationType[] getAwardValidation(){
		List<AwardValidationType> awardValidationTypes = new ArrayList<AwardValidationType>();
		KcServiceLocator.getService(AwardCommonValidationService.class).validateSpecialReviews(award);
		KcServiceLocator.getService(AwardCommonValidationService.class).validateReports(award);
		KcServiceLocator.getService(AwardCommonValidationService.class).validateAwardTerm(award);
		KcServiceLocator.getService(AwardCommonValidationService.class).validateAwardOnCOI(award);


		
		 
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_HUMAN_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_HUMAN_REVIEW));

			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_HUMAN_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_HUMAN_REVIEW));

			 awardValidationTypes.add(awardValidationType);
		 }

		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ANIMAL_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ANIMAL_REVIEW));

			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_DNA_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_DNA_REVIEW));

			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_DNA_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_DNA_REVIEW));

			 awardValidationTypes.add(awardValidationType);
		 }
					
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ISOTOP_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ISOTOP_REVIEW));

			 awardValidationTypes.add(awardValidationType);
		 }
		 
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_ISOTOP_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_ISOTOP_REVIEW));

			 awardValidationTypes.add(awardValidationType);
		 }
					   
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_BIO_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_BIO_REVIEW));

			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_BIO_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_BIO_REVIEW));

			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_INTER_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_INTER_REVIEW));

			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_INTER_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_INTER_REVIEW));
			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_SPECIAL_REVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_SPECIAL_REVIEW));
			 awardValidationTypes.add(awardValidationType);
		 }
		 
		 
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_SPONSOR_CODE)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_SPONSOR_CODE));
			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV));
			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_KP)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_KP));
			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_KP_NOT_CONFIRMED)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_KP_NOT_CONFIRMED));
			 awardValidationTypes.add(awardValidationType);
		 }
		 if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_TERM_SPREVIEW)!=null){
			 AwardValidationType awardValidationType = AwardValidationType.Factory.newInstance();
			 awardValidationType.setValidationDetails(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_TERM_SPREVIEW));
			 awardValidationTypes.add(awardValidationType);
		 }
		return awardValidationTypes.toArray(new AwardValidationType[0]);
	}
	
	public ConfigurationService getKualiConfigurationService() {
		if(kualiConfigurationService==null){
			kualiConfigurationService =  CoreApiServiceLocator.getKualiConfigurationService();
		}
		return kualiConfigurationService;
	}

	public void setKualiConfigurationService(
			ConfigurationService kualiConfigurationService) {
		this.kualiConfigurationService = kualiConfigurationService;
	}

}
