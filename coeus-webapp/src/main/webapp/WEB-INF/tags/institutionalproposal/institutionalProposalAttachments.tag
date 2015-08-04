<%--
 Copyright 2005-2014 The Kuali Foundation
 
 Licensed under the Educational Community License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.osedu.org/licenses/ECL-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
--%>
 <%@ include file="/WEB-INF/jsp/kraTldHeader.jsp"%>
 <style type="text/css">
td.infoline select {
    width:100%;
}
td select {
    width:100%;
}
.voidShadeEnable td{
opacity:.6;
}

.voidShadeDisable td{
opacity:1;
}

</style>

<c:set var="attachments" value="${KualiForm.document.institutionalProposalList[0].instProposalAttachments}"/>
<c:set var="instproposalAttachmentAttributes" value="${DataDictionary.InstitutionalProposalAttachments.attributes}" />
<c:set var="institutionalProposalAttachmentBean" value="${KualiForm.institutionalProposalAttachmentBean}" />
<c:set var="action" value="institutionalProposalAttachments"/>
<c:set var="readOnly" value="${not KualiForm.editingMode['fullEntry']}" scope="request" />
<c:set var="disableAttachmentRemovalIndicator" value="false"/>
<c:if test="${institutionalProposalAttachmentBean.disableAttachmentRemovalIndicator == true}">
<c:set var="disableAttachmentRemovalIndicator" value="true"/>
</c:if>
<kul:tabTop tabTitle="Attachments" defaultOpen="true" tabErrorKey="document.*,institutionalProposalAttachmentBean.*">
	<div class="tab-container" align="center">
   		<h3>
   			<span class="subhead-left">Add Attachment</span>
   		</h3>
       <table id="attachments-table" cellpadding="4" cellspacing="0" summary="">
         	<tr>
         	    <th>
         	    	&nbsp;
         	    </th>
         	    <th>
         			<div align="center">
         				<kul:htmlAttributeLabel attributeEntry="${instproposalAttachmentAttributes.attachmentTypeCode}" noColon="false"/>
         			</div>
         		</th>
         		<th>
         			<div align="center">
         				<kul:htmlAttributeLabel attributeEntry="${instproposalAttachmentAttributes.attachmentTitle}" noColon="false"/>
         			</div>
         		</th>
         		
         		<th>
         			<div align="center">
         				<kul:htmlAttributeLabel attributeEntry="${instproposalAttachmentAttributes.comments}" noColon="false"/>
         			</div>
         		</th>
         		
         		<th>
					<div align="center">
						<kul:htmlAttributeLabel attributeEntry="${instproposalAttachmentAttributes['fileName']}" noColon="false"/>
					</div>
				</th>
				<th>
         			<div align="center">
         				<kul:htmlAttributeLabel attributeEntry="${instproposalAttachmentAttributes.updateTimestamp}" noColon="false" />
         			</div>
         		</th>
         		<th>
         			<div align="center">
         				<kul:htmlAttributeLabel attributeEntry="${instproposalAttachmentAttributes.updateUser}" noColon="false" />
         			</div>
         		</th>
         	
         		<th>
					<div align="center">
						Actions
					</div>
				</th>
				
             </tr>
             
                 <tbody class="addline">
	             <tr>
	             <c:if test="${institutionalProposalAttachmentBean.maintainInstituteProposal == true}">
	                <td align="center" valign="middle" class="infoline">
	                	<div align="center">
	                		Add:
		            	</div>
					</td>
					<td align="left" valign="middle" class="infoline">
	                	<div align="left">
	                		<kul:htmlControlAttribute property="institutionalProposalAttachmentBean.newAttachment.attachmentTypeCode" attributeEntry="${instproposalAttachmentAttributes.attachmentTypeCode}" readOnly="false"/> 
		            	</div>
					</td>
					<td align="left" valign="middle" class="infoline">
	                	<div align="left">
	                		<kul:htmlControlAttribute property="institutionalProposalAttachmentBean.newAttachment.attachmentTitle" attributeEntry="${instproposalAttachmentAttributes.attachmentTitle}" readOnly="false"/> 
		            	</div>
					</td>
	                <td class="infoline">
	              		<div align="center">
	            			<kul:htmlControlAttribute property="institutionalProposalAttachmentBean.newAttachment.comments" attributeEntry="${instproposalAttachmentAttributes.comments}" readOnly="false"/> 
	              		</div>
	            	</td>
	                <td align="left" valign="middle" class="infoline">
	              		<div align="left">
	              		    <c:set var="property" value="institutionalProposalAttachmentBean.newAttachment.newFile" />
	              		    <html:file property="${property}"/>
	           			</div>
					</td> 
					<td align="left" valign="middle" class="infoline">
	                	<div align="left">
	                		<kul:htmlControlAttribute property="institutionalProposalAttachmentBean.newAttachment.updateTimestamp" attributeEntry="${instproposalAttachmentAttributes.updateTimestamp}" readOnly="true"/>
		            	</div>
					</td>
	                <td align="left" valign="middle" class="infoline">
	                	<div align="left">
	                		<kul:htmlControlAttribute property="institutionalProposalAttachmentBean.newAttachment.updateUser" attributeEntry="${instproposalAttachmentAttributes.updateUser}" readOnly="true"/>
		            	</div>
					</td> 
					 
					<td align="center" valign="middle" class="infoline">
						<div align="center">
							<html:image property="methodToCall.addAttachment.anchor${tabKey}"
							src="${ConfigProperties.kra.externalizable.images.url}tinybutton-add1.gif" styleClass="tinybutton addButton"/>
						</div>
					</td>
			   </c:if>
			   </tr>
			<tr>
			
			<c:set var="rowIndex" value="0" />
			<c:forEach var="attachment" items="${attachments}" varStatus="itrStatus">
    			<c:if test="${attachment.viewAttachment}">
    				<c:set var="rowIndex" value="${rowIndex + 1}"/>
					<c:set var="count" value="${itrStatus.index}"/>
					<c:set var="modify" value="${KualiForm.document.institutionalProposalList[0].instProposalAttachments[count].modifyAttachment}"/>
					<c:choose>
					   <c:when test="${modify!=true}">
			             <c:set var="activeModify" value="true"/>
			           </c:when>
				       <c:otherwise>
				         <c:set var="activeModify" value="false"/>
				       </c:otherwise>
				    </c:choose>
				    <c:set var="voidShade" value="voidShadeDisable"/>
				    <c:if test="${KualiForm.document.institutionalProposalList[0].instProposalAttachments[itrStatus.index].documentStatusCode == 'V'  && !modify}">
				    <c:set var="voidShade" value="voidShadeEnable"/>
				    </c:if>
						<tr class="${voidShade}">
			         		  <td>
			         			<div align="center">
			                		${rowIndex}
				            	</div>
			         		</td>  
							<td align="left" valign="middle">
			                	<div align="left">
			                		<kul:htmlControlAttribute property="document.institutionalProposalList[0].instProposalAttachments[${itrStatus.index}].attachmentTypeCode" attributeEntry="${instproposalAttachmentAttributes.attachmentTypeCode}" readOnly="${activeModify}"/>
				            	</div>
							</td>
							<td align="left" valign="middle">
			                	<div align="left">
			                		<kul:htmlControlAttribute property="document.institutionalProposalList[0].instProposalAttachments[${itrStatus.index}].attachmentTitle" attributeEntry="${instproposalAttachmentAttributes.attachmentTitle}" readOnly="${activeModify}"/>
				            	</div>
							</td>
							<td align="left" valign="middle">
			                	<div align="left">
			                		<kul:htmlControlAttribute property="document.institutionalProposalList[0].instProposalAttachments[${itrStatus.index}].comments" attributeEntry="${instproposalAttachmentAttributes.comments}" readOnly="${activeModify}"/>
				            	</div>
							</td>
							 <td align="left" valign="middle">
			           			<div align="left" id="attachmentFileName${itrStatus.index}">
			           			<c:if test="${!readOnly || attachment.file.name!=null}">
			              			 <kra:fileicon attachment="${attachment.file}"/>${attachment.file.name} 
			              	   </c:if>
			           			</div>
							</td> 
							<td align="left" valign="middle">
			                	<div align="left">
			                		<kul:htmlControlAttribute property="document.institutionalProposalList[0].instProposalAttachments[${itrStatus.index}].updateTimestamp" attributeEntry="${instproposalAttachmentAttributes.updateTimestamp}" readOnly="true"/>
				            	</div>
							</td>
			         		<td align="left" valign="middle">
			                	<div align="left">
			                		<kul:htmlControlAttribute property="document.institutionalProposalList[0].instProposalAttachments[${itrStatus.index}].updateUserName" attributeEntry="${instproposalAttachmentAttributes.updateUser}" readOnly="true"/>
				            	</div>
							</td>
							 <td align="center" valign="middle">
								<div align="center">
								<c:if test="${KualiForm.document.institutionalProposalList[0].instProposalAttachments[itrStatus.index].documentStatusCode != 'V'}">
								<c:choose>
								<c:when test="${readOnly}">
								<c:if test="${attachment.viewAttachment}">
								<html:image property="methodToCall.viewAttachment.line${itrStatus.index}.anchor${currentTabIndex}"
										src='${ConfigProperties.kra.externalizable.images.url}tinybutton-view.gif' styleClass="tinybutton"
										alt="View Attachment" onclick="excludeSubmitRestriction = true;"/>
								</c:if>
								</c:when>
								<c:otherwise>
								<html:image property="methodToCall.viewAttachment.line${itrStatus.index}.anchor${currentTabIndex}"
										src='${ConfigProperties.kra.externalizable.images.url}tinybutton-view.gif' styleClass="tinybutton"
										alt="View Attachment" onclick="excludeSubmitRestriction = true;"/>
								</c:otherwise>
								</c:choose>
								</c:if>
								<c:if test="${institutionalProposalAttachmentBean.maintainInstituteProposal == true}">
								<c:choose>
									<c:when test="${institutionalProposalAttachmentBean.disableAttachmentRemovalIndicator == true}">
										<c:if test="${KualiForm.document.institutionalProposalList[0].instProposalAttachments[itrStatus.index].documentStatusCode != 'V'}">
										<html:image property="methodToCall.voidAttachment.line${itrStatus.index}.anchor${currentTabIndex}"
											   src='${ConfigProperties.kra.externalizable.images.url}tinybutton-void.gif' styleClass="tinybutton"
											   alt="Void Attachment"/>
									    </c:if>
									    <c:choose>
									    <c:when test="${!modify}">
									    <html:image property="methodToCall.modifyAttachment.line${itrStatus.index}.anchor${currentTabIndex}"
											   src='${ConfigProperties.kra.externalizable.images.url}tinybutton-modify.gif' styleClass="tinybutton"
											   alt="Modify Attachment"/>
									    </c:when>
									    <c:otherwise>
										  <%-- <c:if test="${!readOnly}"> --%>
		            	                <html:image property="methodToCall.applyModifyAttachment.line${itrStatus.index}.anchor${currentTabIndex}"
								         src="${ConfigProperties.kra.externalizable.images.url}tinybutton-apply.gif" styleClass="tinybutton"/>
		            	                  <%-- </c:if> --%>
		            	                  </c:otherwise>
		            	                  </c:choose>
								   </c:when>
								   <c:otherwise>
								   <html:image property="methodToCall.viewAttachment.line${itrStatus.index}.anchor${currentTabIndex}"
										src='${ConfigProperties.kra.externalizable.images.url}tinybutton-view.gif' styleClass="tinybutton"
										alt="View Attachment" onclick="excludeSubmitRestriction = true;"/>
										<html:image property="methodToCall.deleteAttachment.line${itrStatus.index}.anchor${currentTabIndex}"
											   src='${ConfigProperties.kra.externalizable.images.url}tinybutton-delete1.gif' styleClass="tinybutton"
											   alt="Delete Attachment"/>
								   </c:otherwise>
								   </c:choose>
								   </c:if>
								  </div>
							</td>  
						</tr>

    			</c:if>
			
			</c:forEach>
			</tr>
			</tbody> 
		</table>
     </div>		
</kul:tabTop>
