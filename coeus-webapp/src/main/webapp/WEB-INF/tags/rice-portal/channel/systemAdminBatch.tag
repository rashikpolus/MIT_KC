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

<channel:portalChannelTop channelTitle="Batch" />
<div class="body">
  <ul class="chan">
   <li><a class="portal_link" href="${ConfigProperties.application.url}/personMassChangeHome.do?methodToCall=docHandler&amp;command=initiate&amp;docFormKey=88888888&amp;docTypeName=PersonMassChangeDocument&amp;returnLocation=@{#ConfigProperties['application.url']}%2Fkc-krad%2FlandingPage%3FviewId%3DKc-LandingPage-RedirectView">Perform Person Mass Change</a></li>
    <li>Batch Schedule</li>
  </ul>
</div>
<channel:portalChannelBottom />
