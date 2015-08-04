<%--

    Copyright 2005-2012 The Kuali Foundation

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
<%@ include file="/kr/WEB-INF/jsp/tldHeader.jsp"%>
<html>
  <head>
    <title>Login</title>
    <c:forEach items="${fn:split(ConfigProperties.portal.css.files, ',')}" var="cssFile">
        <c:if test="${fn:length(fn:trim(cssFile)) > 0}">
            <link href="${pageContext.request.contextPath}/${fn:trim(cssFile)}" rel="stylesheet" type="text/css" />
        </c:if>
    </c:forEach>
    <c:forEach items="${fn:split(ConfigProperties.portal.javascript.files, ',')}" var="javascriptFile">
        <c:if test="${fn:length(fn:trim(javascriptFile)) > 0}">
            <script language="JavaScript" type="text/javascript" src="${ConfigProperties.application.url}/${fn:trim(javascriptFile)}"></script>
        </c:if>
    </c:forEach>

    <style type="text/css">
        div.body {
            background-image: url("${ConfigProperties.application.url}/rice-portal/images/os-guy.gif");
            background-repeat: no-repeat;
            padding-top: 5em;
        }

        table#login {
            margin: auto;
            background-color: #dfdda9;
            border: .5em solid #fffdd8;
            /* simple rounded corners for mozilla & webkit */
            -moz-border-radius: 10px;
            -webkit-border-radius: 10px;
        }

        table#login th {
            height: 30 px;
            padding-top: .8em;
            padding-bottom: .8em;
            color: #a02919;
            font-size: 2em;
        }

        #login td {
            padding: .2em;
            height: 20px;
        }

        #login .rightTd {
            padding-right: 1.2em;
        }

        #login .leftTd {
            padding-left: 1.2em;
        }

        table#login td#buttonRow {
            padding-top: 1em;
            padding-bottom: .6em;
        }

    </style>
  </head>

<c:set var="invalidAuthMsg" value="Invalid User. Please contact Application Administrator" />
<div class="body">
          
	<c:if test="${requestScope.invalidAuth}">
			<div align="center">
				<strong>${invalidAuthMsg}</strong>
				<br><a href="${ConfigProperties.application.url}" title="Try Login again"/>Login</a>
			</div>
	</c:if>
</div>
