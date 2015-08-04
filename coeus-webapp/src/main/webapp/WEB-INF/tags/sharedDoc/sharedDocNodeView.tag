<%@ include file="/WEB-INF/jsp/kraTldHeader.jsp"%>

<%@ attribute name="node" required="true" type="org.kuali.coeus.common.framework.medusa.MedusaNode"%>

<div id="medusaNewDetails">
<c:choose>
<c:when test="${node.type == 'IP'}">
  <kra-shared:sharedDocInstPropSummary node="${node}"/>
</c:when>
<c:when test="${node.type == 'award'}">
  <kra-shared:sharedDocAwardSummary node="${node}"/>
</c:when>
<c:when test="${node.type == 'DP'}">
  <kra-shared:sharedDocDevPropSummary node="${node}"/>
</c:when>
<c:when test="${node.type == 'subaward'}">
  <kra-shared:sharedDocSubAwardSummary node="${node}"/>
</c:when>
</c:choose>
</div>


