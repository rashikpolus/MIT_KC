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
package edu.mit.kc.negotiations.lookup;

import org.apache.commons.lang.StringUtils;
import org.kuali.kra.lookup.KraLookupableHelperServiceImpl;
import org.kuali.kra.negotiations.bo.Negotiable;
import org.kuali.kra.negotiations.bo.Negotiation;
import org.kuali.kra.negotiations.lookup.NegotiationDao;
import org.kuali.rice.kew.api.KewApiConstants;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.kns.document.authorization.BusinessObjectRestrictions;
import org.kuali.rice.kns.lookup.HtmlData;
import org.kuali.rice.kns.lookup.HtmlData.AnchorHtmlData;
import org.kuali.rice.kns.lookup.LookupUtils;
import org.kuali.rice.kns.service.KNSServiceLocator;
import org.kuali.rice.kns.web.comparator.CellComparatorHelper;
import org.kuali.rice.kns.web.struts.form.LookupForm;
import org.kuali.rice.kns.web.ui.Column;
import org.kuali.rice.kns.web.ui.Field;
import org.kuali.rice.kns.web.ui.ResultRow;
import org.kuali.rice.kns.web.ui.Row;
import org.kuali.rice.krad.bo.BusinessObject;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.util.BeanPropertyComparator;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.KRADConstants;
import org.kuali.rice.krad.util.ObjectUtils;
import org.kuali.rice.krad.util.UrlFactory;

import java.util.*;

/**
 * Negotiation Lookup Helper Service
 */
public class MitNegotiationLookupableHelperServiceImpl extends KraLookupableHelperServiceImpl {

    private static final long serialVersionUID = -5559605739121335896L;
    private static final String USER_ID = "userId";
   
    private NegotiationDao negotiationDao;


    @SuppressWarnings("unchecked")
    @Override
    public List<? extends BusinessObject> getSearchResults(Map<String, String> fieldValues) {
        super.setBackLocationDocFormKey(fieldValues);
        if (this.getParameters().containsKey(USER_ID)) {
            fieldValues.put("associatedNegotiable.piId", ((String[]) this.getParameters().get(USER_ID))[0]);
            fieldValues.put("negotiatorPersonId", ((String[]) this.getParameters().get(USER_ID))[0]);
        }
        List<Negotiation> searchResults = new ArrayList<Negotiation>();
        searchResults.addAll(getNegotiationDao().getNegotiationResults(fieldValues));

        List defaultSortColumns = getDefaultSortColumns();
        if (defaultSortColumns.size() > 0) {
            Collections.sort(searchResults, new BeanPropertyComparator(defaultSortColumns, true));
        }
        return searchResults;
        
    }
    
    @SuppressWarnings("unchecked")
    @Override
    public List<HtmlData> getCustomActionUrls(BusinessObject businessObject, List pkNames) {
        List<HtmlData> htmlDataList = new ArrayList<HtmlData>();
//        List<HtmlData> htmlDataList = super.getCustomActionUrls(businessObject, pkNames);
        htmlDataList.add(getOpenLink(((Negotiation) businessObject).getDocument()));
        htmlDataList.add(getMedusaLink(((Negotiation) businessObject).getDocument().getDocumentNumber(), false));
        return htmlDataList;
    }
    
    protected AnchorHtmlData getOpenLink(Document document) {
        AnchorHtmlData htmlData = new AnchorHtmlData();
        htmlData.setDisplayText("open");
        Properties parameters = new Properties();
        parameters.put(KRADConstants.DISPATCH_REQUEST_PARAMETER, KRADConstants.DOC_HANDLER_METHOD);
        parameters.put(KRADConstants.PARAMETER_COMMAND, KewApiConstants.DOCSEARCH_COMMAND);
        parameters.put(KRADConstants.DOCUMENT_TYPE_NAME, getDocumentTypeName());
        parameters.put("docId", document.getDocumentNumber());
        String href  = UrlFactory.parameterizeUrl("../" + getHtmlAction(), parameters);
        
        htmlData.setHref(href);
        return htmlData;

    }
    

    
    @Override
    protected String getDocumentTypeName() {
        return "NegotiationDocument";
    }
    
    @Override
    protected String getKeyFieldName() {
        return "negotiationId";
    } 

    @Override
    protected String getHtmlAction() {
        return "negotiationNegotiation.do";
    }



    public NegotiationDao getNegotiationDao() {
        return negotiationDao;
    }



    public void setNegotiationDao(NegotiationDao negotiationDao) {
        this.negotiationDao = negotiationDao;
    }
    
    /**
     * Call's the super class's performLookup function and edits the URLs for the unit name, unit number, sponsor name, and pi name.
     * @see org.kuali.kra.lookup.KraLookupableHelperServiceImpl#performLookup(org.kuali.rice.kns.web.struts.form.LookupForm, java.util.Collection, boolean)
     */
    @Override
    public Collection performLookup(LookupForm lookupForm, Collection resultTable, boolean bounded) {
        final String leadUnitName = "associatedNegotiable.leadUnitName";
        final String leadUnitNumber = "associatedNegotiable.leadUnitNumber";
        final String sponsorName = "associatedNegotiable.sponsorName";
        final String piName = "associatedNegotiable.piName";      
        Collection lookupStuff = getResults(lookupForm, resultTable, bounded);
//        Collection lookupStuff = super.performLookup(lookupForm, resultTable, bounded);
        Iterator i = resultTable.iterator();
        while (i.hasNext()) {
            ResultRow row = (ResultRow) i.next();
            for (Column column : row.getColumns()) {
                //the unit name, pi Name and sponsor name don't need to generate links.
                if (StringUtils.equalsIgnoreCase(column.getPropertyName(), leadUnitName) 
                        || StringUtils.equalsIgnoreCase(column.getPropertyName(), sponsorName)
                        || StringUtils.equalsIgnoreCase(column.getPropertyName(), piName)) {
                    column.setPropertyURL("");
                    for (AnchorHtmlData data : column.getColumnAnchors()) {
                        if (data != null) {
                            data.setHref("");
                        }
                        
                    }
                }
                if (StringUtils.equalsIgnoreCase(column.getPropertyName(), leadUnitNumber)){
                    String unitNumber = column.getPropertyValue();                    
                    //String newUrl = "http://127.0.0.1:8080/kc-dev/kr/inquiry.do?businessObjectClassName=org.kuali.kra.bo.Unit&unitNumber=" + unitNumber + "&methodToCall=start";
                    String newUrl = "inquiry.do?businessObjectClassName=org.kuali.kra.bo.Unit&unitNumber=" + unitNumber + "&methodToCall=start";
                    column.setPropertyURL(newUrl);
                    for (AnchorHtmlData data : column.getColumnAnchors()) {
                        if (data != null) {
                        	data.setHref(newUrl);                        	
                        }
                    }    
                }
            }
        }        
        return lookupStuff;
    }

    
    public Collection<? extends BusinessObject> getResults(LookupForm lookupForm, Collection<ResultRow> resultTable, boolean bounded) {
        Map lookupFormFields = lookupForm.getFieldsForLookup();      
        setBackLocation((String) lookupFormFields.get(KRADConstants.BACK_LOCATION));
        setDocFormKey((String) lookupFormFields.get(KRADConstants.DOC_FORM_KEY));
        Collection<? extends BusinessObject> displayList;

        LookupUtils.preProcessRangeFields(lookupFormFields);

        if (bounded) {
            displayList = getSearchResults(lookupFormFields);
        } else {
            displayList = getSearchResultsUnbounded(lookupFormFields);
        }
        
        if (!lookupForm.isHideReturnLink()) {
            lookupForm.setSuppressActions(true);
        } else {
            lookupForm.setShowMaintenanceLinks(true);
        }

        boolean hasReturnableRow = false;

        List<String> returnKeys = getReturnKeys();
        List<String> pkNames = getBusinessObjectMetaDataService().listPrimaryKeyFieldNames(getBusinessObjectClass());
        Person user = GlobalVariables.getUserSession().getPerson();

        for (BusinessObject element : displayList) {
            BusinessObject baseElement = element;
            Negotiation negotiation= (Negotiation)element;
            if(negotiation.getAssociatedDocument()!=null){
                final String lookupId = KNSServiceLocator.getLookupResultsService().getLookupId(baseElement);
                if (lookupId != null) {
                    lookupForm.setLookupObjectId(lookupId);
                }

                BusinessObjectRestrictions businessObjectRestrictions = getBusinessObjectAuthorizationService()
                        .getLookupResultRestrictions(element, user);

                HtmlData returnUrl = getReturnUrl(element, lookupForm, returnKeys, businessObjectRestrictions);
                String actionUrls = getActionUrls(element, pkNames, businessObjectRestrictions);
                
                getCustomActionUrls(negotiation, pkNames);
                if ("".equals(actionUrls)) {
                    actionUrls = ACTION_URLS_EMPTY;
                }

                List<Column> columns = getColumns();
                for (Iterator iterator = columns.iterator(); iterator.hasNext();) {
                    Column col = (Column) iterator.next();

                    String propValue = ObjectUtils.getFormattedPropertyValue(element, col.getPropertyName(), col.getFormatter());
                    Class propClass = getPropertyClass(element, col.getPropertyName());

                    col.setComparator(CellComparatorHelper.getAppropriateComparatorForPropertyClass(propClass));
                    col.setValueComparator(CellComparatorHelper.getAppropriateValueComparatorForPropertyClass(propClass));

                    String propValueBeforePotientalMasking = propValue;
                    propValue = maskValueIfNecessary(element.getClass(), col.getPropertyName(), propValue,
                            businessObjectRestrictions);
                    col.setPropertyValue(propValue);

                    if (StringUtils.equals(propValueBeforePotientalMasking, propValue)) {
                        if (StringUtils.isNotBlank(col.getAlternateDisplayPropertyName())) {
                            String alternatePropertyValue = ObjectUtils.getFormattedPropertyValue(element, col
                                    .getAlternateDisplayPropertyName(), null);
                            col.setPropertyValue(alternatePropertyValue);
                        }

                        if (StringUtils.isNotBlank(col.getAdditionalDisplayPropertyName())) {
                            String additionalPropertyValue = ObjectUtils.getFormattedPropertyValue(element, col
                                    .getAdditionalDisplayPropertyName(), null);
                            col.setPropertyValue(col.getPropertyValue() + " *-* " + additionalPropertyValue);
                        }
                    } else {
                        col.setTotal(false);
                    }

                    if (col.isTotal()) {
                        Object unformattedPropValue = ObjectUtils.getPropertyValue(element, col.getPropertyName());
                        col.setUnformattedPropertyValue(unformattedPropValue);
                    }

                    if (StringUtils.isNotBlank(propValue)) {
                        col.setColumnAnchor(getInquiryUrl(element, col.getPropertyName()));
                    }
                }

                ResultRow row = new ResultRow(columns, returnUrl.constructCompleteHtmlTag(), actionUrls);
                row.setRowId(returnUrl.getName());
                row.setReturnUrlHtmlData(returnUrl);

                if (getBusinessObjectDictionaryService().isExportable(getBusinessObjectClass())) {
                    row.setBusinessObject(element);
                }

                if (lookupId != null) {
                    row.setObjectId(lookupId);
                }

                boolean rowReturnable = isResultReturnable(element);
                row.setRowReturnable(rowReturnable);
                if (rowReturnable) {
                    hasReturnableRow = true;
                }
                resultTable.add(row);
            }
        }

        lookupForm.setHasReturnableRow(hasReturnableRow);

        return displayList;
    }
    @Override
    protected void setRows() {
        super.setRows();
        List<String> lookupFieldAttributeList = null;
        if (getBusinessObjectMetaDataService().isLookupable(getBusinessObjectClass())) {
            lookupFieldAttributeList = getBusinessObjectMetaDataService().getLookupableFieldNames(
                    getBusinessObjectClass());
        }
        for (Row row : getRows()) {
            for (Field field : row.getFields()) {
                if (StringUtils.equalsIgnoreCase(field.getPropertyName(), "associatedNegotiable.sponsorCode")) {
                    field.setQuickFinderClassNameImpl("org.kuali.kra.bo.Sponsor");
                    field.setFieldConversions("sponsorCode:associatedNegotiable.sponsorCode");
                    field.setLookupParameters("");
                    field.setBaseLookupUrl(LookupUtils.getBaseLookupUrl(false));
                    field.setImageSrc(null);
                    field.setInquiryParameters("associatedNegotiable.sponsorCode:sponsorCode");
                    field.setFieldDirectInquiryEnabled(true);
                } else if (StringUtils.equalsIgnoreCase(field.getPropertyName(), "associatedNegotiable.leadUnitNumber")) {
                    field.setQuickFinderClassNameImpl("org.kuali.kra.bo.Unit");
                    field.setFieldConversions("unitNumber:associatedNegotiable.leadUnitNumber");
                    field.setLookupParameters("");
                    field.setBaseLookupUrl(LookupUtils.getBaseLookupUrl(false));
                    field.setImageSrc(null);
                    field.setInquiryParameters("associatedNegotiable.leadUnitNumber:unitNumber");
                    field.setFieldDirectInquiryEnabled(true);
                }
            }
        }

    }

}
