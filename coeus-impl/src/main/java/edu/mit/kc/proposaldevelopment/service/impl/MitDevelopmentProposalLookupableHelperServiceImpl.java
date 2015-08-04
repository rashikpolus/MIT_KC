package edu.mit.kc.proposaldevelopment.service.impl;

import org.kuali.coeus.common.framework.auth.perm.KcAuthorizationService;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposalLookupableHelperServiceImpl;
import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocument;
import org.kuali.coeus.propdev.impl.state.ProposalState;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.infrastructure.PermissionConstants;
import org.kuali.rice.kns.lookup.HtmlData;
import org.kuali.rice.kns.lookup.HtmlData.AnchorHtmlData;
import org.kuali.rice.kns.service.DocumentHelperService;
import org.kuali.rice.krad.bo.BusinessObject;
import org.kuali.rice.krad.util.GlobalVariables;

import java.util.ArrayList;
import java.util.List;

/**
 * This class...
 */
public class MitDevelopmentProposalLookupableHelperServiceImpl extends DevelopmentProposalLookupableHelperServiceImpl {

    private static final long serialVersionUID = 8611232870631352662L;

    private KcAuthorizationService kraAuthorizationService;
    
       
    /**
     * @see org.kuali.kra.lookup.KraLookupableHelperServiceImpl#getCustomActionUrls(org.kuali.rice.krad.bo.BusinessObject, java.util.List)
     */
    @Override
    public List<HtmlData> getCustomActionUrls(BusinessObject businessObject, List pkNames) {
        ProposalDevelopmentDocument document = ((DevelopmentProposal)businessObject).getProposalDocument();
        String currentUser = GlobalVariables.getUserSession().getPrincipalId();
        List<HtmlData> htmlDataList = new ArrayList<HtmlData>();
        boolean canModifyProposal = kraAuthorizationService.hasPermission(currentUser, document, PermissionConstants.MODIFY_PROPOSAL);
        boolean canViewProposal = kraAuthorizationService.hasPermission(currentUser, document, PermissionConstants.VIEW_PROPOSAL);
        if(canModifyProposal && (document.getDevelopmentProposal().getProposalStateTypeCode().equals(ProposalState.IN_PROGRESS)
                || document.getDevelopmentProposal().getProposalStateTypeCode().equals(ProposalState.REVISIONS_REQUESTED))) {
            AnchorHtmlData editHtmlData = getViewLink(document.getDocumentNumber());
            String href = editHtmlData.getHref();
            href = href.replace("viewDocument=true", "viewDocument=false");
            editHtmlData.setHref(href);
            editHtmlData.setDisplayText("edit");
            htmlDataList.add(editHtmlData);
        }
        if(canViewProposal) {
            AnchorHtmlData viewLink = getViewLink(document.getDocumentNumber());
            htmlDataList.add(viewLink);
            
            htmlDataList.add(getCustomLink(document.getDocumentNumber(), "actions", "copy", !canModifyProposal));
        }
        
        if (canModifyProposal) {
            htmlDataList.add(getMedusaLink(document.getDocumentNumber(), false));
        } else if (canViewProposal) {
            htmlDataList.add(getMedusaLink(document.getDocumentNumber(), true));
        }
        
        return htmlDataList;
    }
    /**
     * Sets the kraAuthorizationService attribute value.
     * @param kraAuthorizationService The kraAuthorizationService to set.
     */
    public void setKraAuthorizationService(KcAuthorizationService kraAuthorizationService) {
        this.kraAuthorizationService = kraAuthorizationService;
    }
    
    public DocumentHelperService getDocumentHelperService() {
        return KcServiceLocator.getService(DocumentHelperService.class);
    }
   
}
