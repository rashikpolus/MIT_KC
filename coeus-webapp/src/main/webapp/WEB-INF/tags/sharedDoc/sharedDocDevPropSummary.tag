<%@ include file="/WEB-INF/jsp/kraTldHeader.jsp"%>

<%@ attribute name="node" required="true" type="org.kuali.coeus.common.framework.medusa.MedusaNode"%>
  <table style="border: 1px solid rgb(147, 147, 147); padding: 0px; width: 97%; border-collapse: collapse;">
    <tr>
      <th colspan="10" style="border-style: solid; text-align: left; border-color: rgb(230, 230, 230) rgb(147, 147, 147) rgb(147, 147, 147); border-width: 1px; padding: 3px; border-collapse: collapse; background-color: rgb(184, 184, 184); background-image: none;">Development Proposal ${node.bo.proposalNumber}</th>
    </tr>
   
      <th colspan="2">Narrative Type</th>
      <th colspan="2">FileName</th>
      <th colspan="2">Title</th>
       <th colspan="2">Uploaded Date</th>
      <th colspan="2">Uploaded User</th>
    </tr>

    <c:forEach items="${node.bo.narratives}" var="pdAttachment" varStatus="itrStatus">
	    	<c:if test="${pdAttachment.viewAttachment}">
			      <tr>
			        <td style="text-align: center;" colspan="2">
			           <c:out value="${pdAttachment.narrativeType.description}"/>                        
			        </td> 
			        <td style="text-align: center;" colspan="2">          
			            <c:out value="${pdAttachment.name}"/>
			            </td> 
			             <td style="text-align: center;" colspan="2">          
			            <c:out value="${pdAttachment.moduleTitle}"/>
			            </td>
			            <td style="text-align: center;" colspan="2">          
			            <c:out value="${pdAttachment.dateUploaded}"/>
			            </td>
			               <td style="text-align: center;" colspan="2">          
			            <c:out value="${pdAttachment.uploadUserFullName}"/>
			            </td>
			         <td colspan="2">
			          <html:image property="methodToCall.viewAttachmentDp.line${itrStatus.index}.anchor${currentTabIndex}.id${pdAttachment.proposalNumber}"
					src='${ConfigProperties.kra.externalizable.images.url}tinybutton-view.gif' styleClass="tinybutton"
					alt="View Attachment" onclick="excludeSubmitRestriction = true;"/>
			        </td>
			      </tr>
	    	</c:if>
    </c:forEach>

  </table>
