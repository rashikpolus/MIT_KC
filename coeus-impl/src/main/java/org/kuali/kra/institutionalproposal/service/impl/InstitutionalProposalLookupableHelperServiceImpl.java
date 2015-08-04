/*
 * Kuali Coeus, a comprehensive research administration system for higher education.
 * 
 * Copyright 2005-2015 Kuali, Inc.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.kuali.kra.institutionalproposal.service.impl;

import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.common.framework.version.VersionStatus;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.institutionalproposal.contacts.InstitutionalProposalPerson;
import org.kuali.kra.institutionalproposal.document.InstitutionalProposalDocument;
import org.kuali.kra.institutionalproposal.document.authorization.InstitutionalProposalDocumentAuthorizer;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.kra.institutionalproposal.proposaladmindetails.ProposalAdminDetails;
import org.kuali.kra.institutionalproposal.service.InstitutionalProposalService;
import org.kuali.kra.lookup.KraLookupableHelperServiceImpl;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.rice.kew.api.KewApiConstants;
import org.kuali.rice.kew.api.exception.WorkflowException;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.kns.lookup.HtmlData;
import org.kuali.rice.kns.lookup.HtmlData.AnchorHtmlData;
import org.kuali.rice.krad.bo.BusinessObject;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.service.DocumentService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.KRADConstants;
import org.kuali.rice.krad.util.UrlFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;

import java.util.*;

/**
 * This class is used to control behavior of Institutional Proposal lookups. Depending
 * on where the lookup is coming from, we may need to add custom action links and/or
 * filter the lookup results.
 */
public class InstitutionalProposalLookupableHelperServiceImpl extends KraLookupableHelperServiceImpl {

    private static final long serialVersionUID = 1L;
    
    private static final String MERGE_PROPOSAL_LOG_ACTION = "mergeProposalLog.do";
    private static final String AWARD_HOME_ACTION = "awardHome.do";
    private static final String OPEN = "open";
    
    private boolean includeMainSearchCustomActionUrls;
    protected String proposalLogNumber;
    private boolean includeMergeCustomActionUrls;
    private DocumentService documentService;
    private InstitutionalProposalService institutionalProposalService;
    
	@Autowired
	@Qualifier("dataObjectService")
	private DataObjectService dataObjectService;

    public void setDocumentService(DocumentService documentService) {
        this.documentService = documentService;
    }
    /* 
     * Overriding this to only return the currently Active version of a proposal 
     */
    @Override
    @SuppressWarnings("unchecked")
    public List<? extends BusinessObject> getSearchResults(Map<String, String> fieldValues) {
        super.setBackLocationDocFormKey(fieldValues);
        
        configureCustomActions(fieldValues);
        
        fieldValues.remove(InstitutionalProposal.PROPOSAL_SEQUENCE_STATUS_PROPERTY_STRING);
        fieldValues.put(InstitutionalProposal.PROPOSAL_SEQUENCE_STATUS_PROPERTY_STRING, VersionStatus.ACTIVE.toString());
        
        Map<String, String> formProps = new HashMap<String, String>();
        if (!StringUtils.isEmpty(fieldValues.get("lookupUnit.unitName"))) {
            formProps.put("units.unit.unitName", fieldValues.get("lookupUnit.unitName"));
        }
        if (!StringUtils.isEmpty(fieldValues.get("lookupUnit.unitNumber"))) {
            formProps.put("units.unitNumber", fieldValues.get("lookupUnit.unitNumber"));
        }
        fieldValues.remove("lookupUnit.unitNumber");
        fieldValues.remove("lookupUnit.unitName");
        if (!formProps.isEmpty()) {
            List<Long> ids = new ArrayList<Long>();
            Collection<InstitutionalProposalPerson> persons = getLookupService().findCollectionBySearch(InstitutionalProposalPerson.class, formProps);
            if (persons.isEmpty()) {
                return new ArrayList<InstitutionalProposal>();
            }
            for (InstitutionalProposalPerson person : persons) {
                ids.add(person.getInstitutionalProposalContactId());
            }
            fieldValues.put("projectPersons.institutionalProposalContactId", StringUtils.join(ids, '|'));
        }
        
        List<InstitutionalProposal> searchResults = (List<InstitutionalProposal>) super.getSearchResults(fieldValues);
      
        if (lookupIsFromAward(fieldValues)) {
            filterAlreadyLinkedProposals(searchResults, fieldValues);
            filterApprovedPendingSubmitProposals(searchResults);
            filterInvalidProposalStatus(searchResults);
        }

        List<InstitutionalProposal> filteredResults = filterForPermissions(searchResults);

        return filteredResults;
    }

    /**
     * This method filters results so that the person doing the lookup only gets back the documents he can view.
     * @param results
     * @return
     */
    protected List<InstitutionalProposal> filterForPermissions(List<InstitutionalProposal> results) {
        Person user = GlobalVariables.getUserSession().getPerson();
        InstitutionalProposalDocumentAuthorizer authorizer = new InstitutionalProposalDocumentAuthorizer();
        List<InstitutionalProposal> filteredResults = new ArrayList<InstitutionalProposal>();
        
        for (InstitutionalProposal institutionalProposal : results) {
            
            String documentNumber = institutionalProposal.getInstitutionalProposalDocument().getDocumentNumber();
            try {
                InstitutionalProposalDocument document = (InstitutionalProposalDocument) documentService.getByDocumentHeaderId(documentNumber);
                
                if (authorizer.canOpen(document, user)) {
                    filteredResults.add(institutionalProposal);
                }
            } catch (WorkflowException e) {
                LOG.warn("Cannot find Document with header id " + documentNumber);
            }
        }

        
        return filteredResults;
    }
    
    
    @SuppressWarnings("unchecked")
    @Override
    public List<HtmlData> getCustomActionUrls(BusinessObject businessObject, List pkNames) {
        List<HtmlData> htmlDataList = new ArrayList<HtmlData>();
        if (includeMainSearchCustomActionUrls) {
            htmlDataList.add(getOpenLink(((InstitutionalProposal) businessObject).getInstitutionalProposalDocument()));
        } 
        if (includeMergeCustomActionUrls) {
            htmlDataList.add(getSelectLink((InstitutionalProposal) businessObject));
        }
        htmlDataList.add(getMedusaLink(((InstitutionalProposal) businessObject).getInstitutionalProposalDocument().getDocumentNumber(), false));
        return htmlDataList;
    }
    
    protected AnchorHtmlData getOpenLink(Document document) {
        AnchorHtmlData htmlData = new AnchorHtmlData();
        htmlData.setDisplayText(OPEN);
        Properties parameters = new Properties();
        parameters.put(KRADConstants.DISPATCH_REQUEST_PARAMETER, KRADConstants.DOC_HANDLER_METHOD);
        parameters.put(KRADConstants.PARAMETER_COMMAND, KewApiConstants.DOCSEARCH_COMMAND);
        parameters.put(KRADConstants.DOCUMENT_TYPE_NAME, getDocumentTypeName());
        parameters.put("viewDocument", "true");
        parameters.put("docOpenedFromIPSearch", "true");
        parameters.put("docId", document.getDocumentNumber());
        String href  = UrlFactory.parameterizeUrl("../"+getHtmlAction(), parameters);
        
        htmlData.setHref(href);
        return htmlData;

    }


    @Override
    protected String getHtmlAction() {
        return "institutionalProposalHome.do";
    }
    
    @Override
    protected String getDocumentTypeName() {
        return "InstitutionalProposalDocument";
    }
    
    @Override
    protected String getKeyFieldName() {
        return InstitutionalProposal.PROPOSAL_NUMBER_PROPERTY_STRING;
    }
    
    protected boolean lookupIsFromAward(Map<String, String> fieldValues) {
        String returnLocation = fieldValues.get(KRADConstants.BACK_LOCATION);
        return returnLocation != null && returnLocation.contains(AWARD_HOME_ACTION);
    }
    
    /* 
     * Filters will set flag in IP indicating that they should not be selectable
     * in an Award-based search if they are already linked, if they are Approval Pending Submitted, or if
     * they are not of status 1, 2, or 4. We do this here (instead of in the IP object itself) because
     * this object knows the origin of the lookup, and can easily determine if the IP is already linked.
     */
    /*
     * This method filters out IP's which are already linked to proposals
     */
    @SuppressWarnings("unchecked")
    protected void filterAlreadyLinkedProposals(List<? extends BusinessObject> searchResults, Map<String, String> fieldValues) {
        List<Long> linkedProposals = (List<Long>) GlobalVariables.getUserSession().retrieveObject(Constants.LINKED_FUNDING_PROPOSALS_KEY);
        if (linkedProposals == null) { return; }
        for (Long linkedProposalId : linkedProposals) {
            for (int j = 0; j < searchResults.size(); j++) {
                InstitutionalProposal institutionalProposal = (InstitutionalProposal) searchResults.get(j);
                if (linkedProposalId.equals(institutionalProposal.getProposalId())) {
                    institutionalProposal.setShowReturnLink(false);
                    break;
                }
            }
        }
    }
    
    /*
     * This method filters out IP's which were generated from PD whose ProposeStateType is "Approval Pending Submitted"
     */
    protected void filterApprovedPendingSubmitProposals(List<? extends BusinessObject> searchResults) {
        for (int j = 0; j < searchResults.size(); j++) {
            if (isDevelopmentProposalAppPendingSubmitted((InstitutionalProposal) searchResults.get(j))) {
                ((InstitutionalProposal)searchResults.get(j)).setShowReturnLink(false);
            }
        }
    }

    /**
     * This method is to filter out IP's not having codes in the valid funding proposal status codes parameter.
     **/
    protected void filterInvalidProposalStatus(List<? extends BusinessObject> searchResults) {
        Collection<String> validCodes = getInstitutionalProposalService().getValidFundingProposalStatusCodes();           
        for (int j = 0; j < searchResults.size(); j++) {
            InstitutionalProposal result = (InstitutionalProposal) searchResults.get(j);
            if (!validCodes.contains(result.getStatusCode().toString())) {
                result.setShowReturnLink(false);
            }
        }
    }

    /**
     * Find if any proposal associate with this INSP has 'Approval Pending Submitted' proposal state type
     **/
    protected boolean isDevelopmentProposalAppPendingSubmitted(InstitutionalProposal ip) {
        boolean isApprovePending = false;
        Collection<DevelopmentProposal> devProposals = getDevelopmentProposals(ip);
        for (DevelopmentProposal developmentProposal : devProposals) {
            if ("5".equals(developmentProposal.getProposalStateTypeCode())) {
                isApprovePending = true;
                break;
            }
        }
        return isApprovePending;
    }

    /*
     * find any version of IP that has PD with approve pending
     */
    @SuppressWarnings("unchecked")
    protected Collection<DevelopmentProposal> getDevelopmentProposals(InstitutionalProposal instProposal) {
        //find any dev prop linked to any version of this inst prop
        Collection<DevelopmentProposal> devProposals = new ArrayList<DevelopmentProposal>();
        List<ProposalAdminDetails> proposalAdminDetails = (List<ProposalAdminDetails>) businessObjectService.findMatchingOrderBy(ProposalAdminDetails.class, 
                                                                getFieldValues("instProposalId", instProposal.getProposalId()), "devProposalNumber", true);
        if(proposalAdminDetails.size() > 0) {
            String latestDevelopmentProposalDocNumber = proposalAdminDetails.get(proposalAdminDetails.size() - 1).getDevProposalNumber();
            DevelopmentProposal devProp = (DevelopmentProposal)dataObjectService.find(DevelopmentProposal.class, latestDevelopmentProposalDocNumber);
            devProposals.add(devProp);
        }
        return devProposals;
    }

    protected Map<String, Object> getFieldValues(String key, Object value){
        Map<String, Object> fieldValues = new HashMap<String, Object>();
        fieldValues.put(key, value);
        return fieldValues;
    }

    /* 
     * Determine whether lookup is being called from a location that shouldn't include the custom action links
     */
    protected void configureCustomActions(Map<String, String> fieldValues) {
        String returnLocation = fieldValues.get(KRADConstants.BACK_LOCATION);
        if (returnLocation != null) {
            if (returnLocation.contains(AWARD_HOME_ACTION)) {
                includeMainSearchCustomActionUrls = false;
                includeMergeCustomActionUrls = false;
            } else if (returnLocation.contains(MERGE_PROPOSAL_LOG_ACTION)) {
                includeMainSearchCustomActionUrls = false;
                includeMergeCustomActionUrls = true;
                setProposalLogNumber(fieldValues.get("proposalLogNumber"));
            } else {
                includeMainSearchCustomActionUrls = true;
                includeMergeCustomActionUrls = false;
            }
        } else {
            includeMainSearchCustomActionUrls = false;
            includeMergeCustomActionUrls = false;
        }
    }
    
    protected AnchorHtmlData getSelectLink(InstitutionalProposal institutionalProposal) {
        AnchorHtmlData htmlData = new AnchorHtmlData();
        htmlData.setDisplayText("select");
        Properties parameters = new Properties();
        parameters.put(KRADConstants.DISPATCH_REQUEST_PARAMETER, "mergeToInstitutionalProposal");
        parameters.put("institutionalProposalNumber", institutionalProposal.getProposalNumber());
        if (getProposalLogNumber() != null) {
            parameters.put("proposalLogNumber", getProposalLogNumber());
        }
        String href  = UrlFactory.parameterizeUrl("../" + MERGE_PROPOSAL_LOG_ACTION, parameters);
        htmlData.setHref(href);
        return htmlData;
    }

    @Override
    public boolean isResultReturnable(BusinessObject object) {
        InstitutionalProposal institutionalProposal = (InstitutionalProposal)object;
        return institutionalProposal.getShowReturnLink();
    }
    
    protected InstitutionalProposalService getInstitutionalProposalService() {
        return institutionalProposalService;
    }
    public void setInstitutionalProposalService(InstitutionalProposalService institutionalProposalService) {
        this.institutionalProposalService = institutionalProposalService;
    }
	protected DataObjectService getDataObjectService() {
		return dataObjectService;
	}
	public void setDataObjectService(DataObjectService dataObjectService) {
		this.dataObjectService = dataObjectService;
	}


    protected void setProposalLogNumber(final String proposalLogNumber) {
        this.proposalLogNumber = proposalLogNumber;
    }

    protected String getProposalLogNumber() {
        return this.proposalLogNumber;
    }
}