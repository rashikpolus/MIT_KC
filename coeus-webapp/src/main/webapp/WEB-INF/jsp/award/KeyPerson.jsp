<%--
 Copyright 2005-2014 The Kuali Foundation

 Licensed under the GNU Affero General Public License, Version 3 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.osedu.org/licenses/ECL-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
--%>
<!-- AwardMedusa.jsp -->

<%@ include file="/WEB-INF/jsp/kraTldHeader.jsp"%>

<kul:documentPage showDocumentInfo="true"
	htmlFormAction="keyperson" documentTypeName="AwardDocument"
	renderMultipart="false" showTabButtons="true" auditCount="0"
	headerDispatch="${KualiForm.headerDispatch}" headerTabActive="keyperson">
	<kul:tabTop tabTitle="Project Documents" defaultOpen="true"
		tabErrorKey="">
		<kra-shared:awardKeyPersonnel />
	<html:text property="navigateFlag" value="keyperson" style="display: none;"/>
	</kul:tabTop>
	<kul:panelFooter />
	<div id="globalbuttons" class="globalbuttons">
		
	      	<html:image src="${ConfigProperties.kr.externalizable.images.url}buttonsmall_save.gif" styleClass="globalbuttons" property="methodToCall.save" styleId="save" title="save" alt="save"/>
	    	
		<html:image
			src="${ConfigProperties.kr.externalizable.images.url}buttonsmall_close.gif"
			styleClass="globalbuttons" property="methodToCall.close"
			title="close" alt="close" onclick="excludeSubmitRestriction=true" />
	</div>
</kul:documentPage>
