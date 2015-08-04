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
package edu.mit.kc.proposallog.service.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.common.framework.person.KcPerson;
import org.kuali.coeus.common.framework.person.KcPersonService;
import org.kuali.kra.institutionalproposal.proposallog.ProposalLog;
import org.kuali.kra.institutionalproposal.proposallog.ProposalLogDocumentAuthorizer;
import org.kuali.kra.institutionalproposal.proposallog.ProposalLogLookupableHelperServiceImpl;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.kns.lookup.HtmlData;
import org.kuali.rice.kns.lookup.KualiLookupableHelperServiceImpl;
import org.kuali.rice.kns.lookup.HtmlData.AnchorHtmlData;
import org.kuali.rice.kns.web.struts.form.LookupForm;
import org.kuali.rice.kns.web.ui.Field;
import org.kuali.rice.kns.web.ui.Row;
import org.kuali.rice.krad.bo.BusinessObject;
import org.kuali.rice.krad.document.DocumentAuthorizer;
import org.kuali.rice.krad.document.DocumentPresentationController;
import org.kuali.rice.krad.exception.DocumentAuthorizationException;
import org.kuali.rice.krad.service.DocumentDictionaryService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.KRADConstants;
import org.kuali.rice.krad.util.UrlFactory;

/**
 * Lookupable helper service used for proposal log lookup
 */     
public class MitProposalLogLookupableHelperServiceImpl extends ProposalLogLookupableHelperServiceImpl {   
	 private static final long serialVersionUID = -7638045643796948730L;
	    
	    private static final String USERNAME_FIELD = "person.userName";
	    private static final String STATUS_PENDING = "1";
	    public static final String MAINTENANCE_MERGE_LINK = "merge";
	    private boolean isLookupForProposalCreation;
	    private KcPersonService kcPersonService;
	    private DocumentDictionaryService documentDictionaryService;	   
	 @Override
	    public List<HtmlData> getCustomActionUrls(BusinessObject businessObject, List pkNames) {
	        List<HtmlData> htmlDataList = new ArrayList<HtmlData>();
	        htmlDataList =super.getCustomActionUrls(businessObject, pkNames);
	        removeMergeLink(htmlDataList);
	        return htmlDataList;
	    }
	    public void setKcPersonService(KcPersonService kcPersonService) {
	        this.kcPersonService = kcPersonService;
	    }

	    public KcPersonService getKcPersonService() {
	        return kcPersonService;
	    }

	    public DocumentDictionaryService getDocumentDictionaryService() {
	        return documentDictionaryService;
	    }

	    public void setDocumentDictionaryService(DocumentDictionaryService documentDictionaryService) {
	        this.documentDictionaryService = documentDictionaryService;
	    } 
	    protected void removeMergeLink(List<HtmlData> htmlDataList) {
	        int mergeLinkIndex = -1;
	        int currentIndex = 0;
	        for(int i=0;i<htmlDataList.size();i++){
	        	AnchorHtmlData htmlData=(AnchorHtmlData) htmlDataList.get(i);	        	
	        	if((htmlData.getDisplayText()).equals(MAINTENANCE_MERGE_LINK)){
	        		mergeLinkIndex = currentIndex;
	        		 break;
	        	}
	        	 currentIndex++;
	        }
	        if (mergeLinkIndex != -1) {
	            htmlDataList.remove(mergeLinkIndex);
	        }
	    } 
}
