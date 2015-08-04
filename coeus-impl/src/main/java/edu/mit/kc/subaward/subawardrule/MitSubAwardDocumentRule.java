/*
 * 
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
package edu.mit.kc.subaward.subawardrule;

import org.kuali.kra.institutionalproposal.document.InstitutionalProposalDocument;
import org.kuali.kra.subaward.bo.SubAward;
import org.kuali.kra.subaward.document.SubAwardDocument;
import org.kuali.kra.subaward.subawardrule.SubAwardDocumentRule;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.document.TransactionalDocument;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.KRADConstants;

public class MitSubAwardDocumentRule extends SubAwardDocumentRule  {

	 @Override
	    public boolean processSaveDocument(Document document) {
	        boolean isValid = true;

	        isValid = isDocumentOverviewValid(document);

	        GlobalVariables.getMessageMap().addToErrorPath(KRADConstants.DOCUMENT_PROPERTY_NAME);
	        SubAwardDocument subAwardDocument = (SubAwardDocument)document;
	        if(subAwardDocument.getSubAward().getSequenceNumber()== 1 || 
	                (subAwardDocument.getSubAward().getSequenceNumber()!=1 && !subAwardDocument.getDocumentHeader().getWorkflowDocument().getStatus().getCode().equals("I"))){
	            
	            getKnsDictionaryValidationService().validateDocumentAndUpdatableReferencesRecursively(document, getMaxDictionaryValidationDepth(),
	                    VALIDATION_REQUIRED, CHOMP_LAST_LETTER_S_FROM_COLLECTION_NAME);
	            getDictionaryValidationService().validateDefaultExistenceChecksForTransDoc((TransactionalDocument) document);
	        }

	            GlobalVariables.getMessageMap().removeFromErrorPath(KRADConstants.DOCUMENT_PROPERTY_NAME);
	        

	        isValid &= GlobalVariables.getMessageMap().hasNoErrors();
	        isValid &= processCustomSaveDocumentBusinessRules(document);

	        return isValid;
	    }
  
}