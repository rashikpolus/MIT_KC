
<%@ include file="/WEB-INF/jsp/kraTldHeader.jsp"%>
<c:forEach items="${KualiForm.medusaBean.parentNodes}" var="parentNode">
  <kra-shared:sharedDocTreeNode node="${parentNode}"/>
</c:forEach>