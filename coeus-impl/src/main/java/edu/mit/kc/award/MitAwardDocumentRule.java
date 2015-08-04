/*
 * Copyright 2005-2014 The Kuali Foundation
 *
 * Licensed under the GNU Affero General Public License, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.osedu.org/licenses/ECL-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package edu.mit.kc.award;

import org.kuali.kra.award.AwardDocumentRule;
import org.kuali.kra.award.document.AwardDocument;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.document.TransactionalDocument;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.KRADConstants;





/**
 * Main Business Rule class for <code>{@link AwardDocument}</code>. 
 * Responsible for delegating rules to independent rule classes.
 *
 */
public class MitAwardDocumentRule extends AwardDocumentRule {
    
	 @Override
	    public boolean processSaveDocument(Document document) {
	        boolean isValid = true;

	        isValid = isDocumentOverviewValid(document);

	        GlobalVariables.getMessageMap().addToErrorPath(KRADConstants.DOCUMENT_PROPERTY_NAME);
	        AwardDocument awardDocument = (AwardDocument)document;
	        if(awardDocument.getAward().getSequenceNumber()== 1 || 
	                (awardDocument.getAward().getSequenceNumber()!=1 && !awardDocument.getDocumentHeader().getWorkflowDocument().getStatus().getCode().equals("I"))){
	            
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
