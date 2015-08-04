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
package org.kuali.coeus.common.impl.workflow;

import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocument;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.award.document.AwardDocument;
import org.kuali.kra.committee.document.CommitteeDocument;
import org.kuali.kra.iacuc.IacucProtocolDocument;
import org.kuali.kra.irb.ProtocolDocument;
import org.kuali.kra.kim.bo.KcKimAttributes;
import org.kuali.kra.negotiations.document.NegotiationDocument;
import org.kuali.kra.subaward.document.SubAwardDocument;
import org.kuali.rice.core.api.exception.RiceIllegalArgumentException;
import org.kuali.rice.core.api.uif.RemotableAttributeError;
import org.kuali.rice.core.api.uif.RemotableAttributeField;
import org.kuali.rice.kew.api.document.Document;
import org.kuali.rice.kew.api.document.DocumentContent;
import org.kuali.rice.kew.api.exception.WorkflowException;
import org.kuali.rice.kew.framework.peopleflow.PeopleFlowTypeService;
import org.kuali.rice.krad.service.DocumentService;
import org.springframework.stereotype.Component;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component("kcPeopleFlowTypeService")
public class KcPeopleFlowTypeServiceImpl implements PeopleFlowTypeService {

	private static final Log LOG = LogFactory.getLog(KcPeopleFlowTypeServiceImpl.class);
	
    @Override
    public List<String> filterToSelectableRoleIds(String kewTypeId, List<String> roleIds) {

        return roleIds;
    }

    @Override
    public Map<String, String> resolveRoleQualifiers(String kewTypeId, String roleId, Document document,
            DocumentContent documentContent) {
    	Map<String,String> peopleFlowRoleQualifiers = getPeopleFlowRoleQualiFier(document.getDocumentId());
        return peopleFlowRoleQualifiers;
    }

    @Override
    public List<RemotableAttributeField> getAttributeFields(String kewTypeId) {

        return Collections.emptyList();
    }

    @Override
    public List<RemotableAttributeError> validateAttributes(String kewTypeId, Map<String, String> attributes)
            throws RiceIllegalArgumentException {

        return Collections.emptyList();
    }

    @Override
    public List<RemotableAttributeError> validateAttributesAgainstExisting(String kewTypeId, Map<String, String> newAttributes,
            Map<String, String> oldAttributes) throws RiceIllegalArgumentException {

        return Collections.emptyList();
    }

    @Override
    public List<Map<String, String>> resolveMultipleRoleQualifiers(String arg0, String arg1, Document arg2, DocumentContent arg3) {
        return null;
    }

    private Map<String,String> getPeopleFlowRoleQualiFier(String documentId){
    	DocumentService documentService = KcServiceLocator.getService(DocumentService.class);
    	Map<String,String> qualifiers = new HashMap<String, String>();
    	qualifiers.put(KcKimAttributes.DOCUMENT_NUMBER, documentId);
		try {
			org.kuali.rice.krad.document.Document document = documentService.getByDocumentHeaderId(documentId);
			if(document instanceof AwardDocument){
				AwardDocument awardDocument = (AwardDocument)document;
				qualifiers.put(KcKimAttributes.AWARD,awardDocument.getAward().getAwardId().toString());
				qualifiers.put(KcKimAttributes.UNIT_NUMBER, awardDocument.getAward().getLeadUnitNumber());
			}if(document instanceof ProposalDevelopmentDocument){
				ProposalDevelopmentDocument proposalDevelopmentDocument = (ProposalDevelopmentDocument)document;
				qualifiers.put(KcKimAttributes.PROPOSAL,proposalDevelopmentDocument.getDevelopmentProposal().getProposalNumber());
				qualifiers.put(KcKimAttributes.UNIT_NUMBER, proposalDevelopmentDocument.getDevelopmentProposal().getUnitNumber());
			}if(document instanceof IacucProtocolDocument){
				IacucProtocolDocument iacucProtocolDocument = (IacucProtocolDocument)document;
				qualifiers.put(KcKimAttributes.PROTOCOL,iacucProtocolDocument.getIacucProtocol().getProtocolNumber());
				qualifiers.put(KcKimAttributes.UNIT_NUMBER, iacucProtocolDocument.getIacucProtocol().getLeadUnitNumber());
			}if(document instanceof ProtocolDocument){
				ProtocolDocument protocolDocument = (ProtocolDocument)document;
				qualifiers.put(KcKimAttributes.PROTOCOL,protocolDocument.getProtocol().getProtocolNumber());
				qualifiers.put(KcKimAttributes.UNIT_NUMBER, protocolDocument.getProtocol().getLeadUnitNumber());
			}if(document instanceof CommitteeDocument){
				CommitteeDocument committeeDocument = (CommitteeDocument)document;
				qualifiers.put(KcKimAttributes.COMMITTEE,committeeDocument.getCommitteeId());
				qualifiers.put(KcKimAttributes.UNIT_NUMBER, committeeDocument.getCommittee().getLeadUnitNumber());
			}if(document instanceof NegotiationDocument){
				NegotiationDocument negotiationDocument = (NegotiationDocument)document;
				qualifiers.put(KcKimAttributes.NEGOTIATION,negotiationDocument.getNegotiation().getNegotiationId().toString());
				qualifiers.put(KcKimAttributes.UNIT_NUMBER, negotiationDocument.getNegotiation().getLeadUnitNumber());
			}if(document instanceof SubAwardDocument){
				SubAwardDocument subAwardDocument = (SubAwardDocument)document;
				qualifiers.put(KcKimAttributes.SUBAWARD,subAwardDocument.getSubAward().getSubAwardId().toString());
				qualifiers.put(KcKimAttributes.UNIT_NUMBER, subAwardDocument.getSubAward().getLeadUnitNumber());
			}
		} catch (WorkflowException e) {
    		LOG.error(e.getMessage(), e);
    	}
    	
    	
    	
		return qualifiers;
    }
}
