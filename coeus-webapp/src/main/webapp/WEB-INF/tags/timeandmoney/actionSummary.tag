<%--
   - Kuali Coeus, a comprehensive research administration system for higher education.
   - 
   - Copyright 2005-2015 Kuali, Inc.
   - 
   - This program is free software: you can redistribute it and/or modify
   - it under the terms of the GNU Affero General Public License as
   - published by the Free Software Foundation, either version 3 of the
   - License, or (at your option) any later version.
   - 
   - This program is distributed in the hope that it will be useful,
   - but WITHOUT ANY WARRANTY; without even the implied warranty of
   - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   - GNU Affero General Public License for more details.
   - 
   - You should have received a copy of the GNU Affero General Public License
   - along with this program.  If not, see <http://www.gnu.org/licenses/>.
--%>
<%@ include file="/WEB-INF/jsp/kraTldHeader.jsp"%>

<c:set var="awardAmountInfoAttributes" value="${DataDictionary.AwardAmountInfo.attributes}" />
<c:set var="awardAmountTransactionAttributes" value="${DataDictionary.AwardAmountTransaction.attributes}" />

<kul:tab tabTitle="Action Summary (${KualiForm.document.awardNumber})" defaultOpen="true" tabErrorKey="">
	<div class="tab-container" align="center">
    	<h3>
    		<span class="subhead-left"> Action Summary</span>
    		<span class="subhead-right"><kul:help parameterNamespace="KC-T" parameterDetailType="Document" parameterName="tmActionSummaryHelpUrl" altText="help"/></span>
  </h3>

	<c:if test="${KualiForm.inMultipleNodeHierarchy}" >
			
  			<table cellpadding="0" cellspacing="0" summary="">	
			<tr>
				<th>
					<div align="left">
						Go To:
						<html:select property="goToAwardNumber">
		                    <c:forEach items="${krafn:getOptionList('org.kuali.kra.timeandmoney.AwardValuesFinder', null)}" var="option">
		                    <c:choose>
		                        <c:when test="${KualiForm.goToAwardNumber == option.key}">
		                        <option value="${option.key}" selected="">${option.value}</option>
		                        </c:when>
		                        <c:otherwise>
		                        <option value="${option.key}">${option.value}</option>
		                        </c:otherwise>
		                    </c:choose>
		                    </c:forEach>
						</html:select> 
						<html:image src="${ConfigProperties.kra.externalizable.images.url}tinybutton-go.gif" styleClass="globalbuttons" alt="Go" property="methodToCall.timeAndMoneySummaryAndHistory" />
					</div>
				</th>
			</tr>
		</table>
		
		</c:if>

        
        <table cellpadding="0" cellspacing="0" summary="">
        	<tr>
        		<th>
					<div align="center"><kul:htmlAttributeLabel attributeEntry="${awardAmountTransactionAttributes.noticeDate}" readOnly="true" noColon="true" /></div>
       			</th>
       			<th>
					<div align="center"><kul:htmlAttributeLabel attributeEntry="${awardAmountTransactionAttributes.transactionTypeCode}" readOnly="true" noColon="true" /></div>
       			</th>
       			
        		<th>
					<div align="center"><kul:htmlAttributeLabel attributeEntry="${awardAmountInfoAttributes.currentFundEffectiveDate}" readOnly="true" noColon="true" /></div>
       			</th>
       			<th>
					<div align="center"><kul:htmlAttributeLabel attributeEntry="${awardAmountInfoAttributes.obligationExpirationDate}" readOnly="true" noColon="true" /></div>
       			</th>
       			<th>
					<div align="center"><kul:htmlAttributeLabel attributeEntry="${awardAmountInfoAttributes.amountObligatedToDate}" readOnly="true" noColon="true" /></div>
       			</th>
       			<th>
					<div align="center"><kul:htmlAttributeLabel attributeEntry="${awardAmountInfoAttributes.obligatedChange}" readOnly="true" noColon="true" /></div>
       			</th>        	
        	</tr>
        	<c:forEach var="timeAndMoneyActionSummaryItems" items="${KualiForm.document.timeAndMoneyActionSummaryItems}" varStatus="status">
        	<tr>
        		<td class="datacell"><div>
        			<fmt:formatDate value="${timeAndMoneyActionSummaryItems.noticeDate}" pattern="MM/dd/yyyy" />
				</div></td>
				<td class="datacell"><div>								        		
					${timeAndMoneyActionSummaryItems.transactionType}
				</div></td>
				<td class="datacell"><div>
					<fmt:formatDate value="${timeAndMoneyActionSummaryItems.obligationStartDate}" pattern="MM/dd/yyyy" />
				</div></td>
				<td class="datacell"><div>
					<fmt:formatDate value="${timeAndMoneyActionSummaryItems.obligationEndDate}" pattern="MM/dd/yyyy" />
				</div></td>
				<td class="datacell"><div>				        		
					<fmt:formatNumber type="currency" currencySymbol="" value="${timeAndMoneyActionSummaryItems.obligationCumulative}"/>
				</div></td>
				<td class="datacell"><div>				        		
					<fmt:formatNumber type="currency" currencySymbol="" value="${timeAndMoneyActionSummaryItems.changeAmount}"/>
				</div></td>
        	</tr>
        	</c:forEach>
        
        </table>
    </div>    
</kul:tab>
