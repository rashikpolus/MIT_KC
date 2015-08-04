<%--
 Copyright 2007-2009 The Kuali Foundation

 Licensed under the Educational Community License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.opensource.org/licenses/ecl2.php

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
--%>
<%@ include file="/rice-portal/jsp/sys/riceTldHeader.jsp" %>

<channel:portalChannelTop channelTitle="KRMS Workflow"/>
<div class="body">
    
  <ul class="chan">
                         
   <li><a class="portal_link" href="${ConfigProperties.application.url}/kr-krad/lookup?methodToCall=start&amp;dataObjectClassName=org.kuali.rice.kew.impl.peopleflow.PeopleFlowBo&amp;showMaintenanceLinks=true&amp;returnLocation=@{#ConfigProperties['application.url']}%2Fkc-krad%2FlandingPage%3FviewId%3DKc-LandingPage-RedirectView&amp;hideReturnLink=true">View People Flow</a></li>
   <li><a class="portal_link" href="${ConfigProperties.application.url}/kew/RoutingReport.do?returnLocation=@{#ConfigProperties['application.url']}%2Fkc-krad%2FlandingPage%3FviewId%3DKc-LandingPage-RedirectView">View Routing Report</a></li>
   <li><a class="portal_link" href="${ConfigProperties.application.url}/kew/RuleQuickLinks.do?returnLocation=@{#ConfigProperties['application.url']}%2Fkc-krad%2FlandingPage%3FviewId%3DKc-LandingPage-RedirectView">View Rule QuickLinks</a></li>
   <li><a class="portal_link" href="${ConfigProperties.krad.url}/lookup?methodToCall=start&dataObjectClassName=org.kuali.rice.krms.impl.repository.AgendaBo&showMaintenanceLinks=true&returnLocation=${ConfigProperties.application.url}/portal.do&hideReturnLink=true">View Agendas</a></li>
   <li><a class="portal_link" href="${ConfigProperties.krad.url}/lookup?methodToCall=start&dataObjectClassName=org.kuali.rice.krms.impl.repository.RuleBo&showMaintenanceLinks=true&returnLocation=${ConfigProperties.application.url}/portal.do&hideReturnLink=true">View Business Rules</a></li>
   <li><a class="portal_link" href="${ConfigProperties.krad.url}/lookup?methodToCall=start&dataObjectClassName=org.kuali.rice.krms.impl.repository.TermSpecificationBo&showMaintenanceLinks=true&returnLocation=${ConfigProperties.application.url}/portal.do&hideReturnLink=true">View Term Specifications</a></li>
   <li><a class="portal_link" href="${ConfigProperties.krad.url}/lookup?methodToCall=start&dataObjectClassName=org.kuali.rice.krms.impl.repository.TermBo&showMaintenanceLinks=true&returnLocation=${ConfigProperties.application.url}/portal.do&hideReturnLink=true">View Terms</a></li>
   <li><portal:portalLink displayTitle="true" title="View KRMS Functions" url="${ConfigProperties.krad.url}/lookup?methodToCall=start&dataObjectClassName=edu.mit.kc.bo.KrmsFunctions&showMaintenanceLinks=true&returnLocation=${ConfigProperties.application.url}/portal.do&hideReturnLink=true" /></li>
   <li><portal:portalLink displayTitle="true" title="View KRMS Function Params" url="${ConfigProperties.krad.url}/lookup?methodToCall=start&dataObjectClassName=edu.mit.kc.bo.KrmsFunctionsParams&showMaintenanceLinks=true&returnLocation=${ConfigProperties.application.url}/portal.do&hideReturnLink=true" /></li>
  </ul>

</div>
<channel:portalChannelBottom/>