/*
 * Kuali Coeus, a comprehensive research administration system for higher education.
 * 
 * Copyright 2005-2015 Kuali, Inc.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.kuali.coeus.propdev.impl.core;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.kuali.coeus.propdev.impl.sapfeed.SapFeedsForm;
import org.kuali.coeus.sys.framework.controller.KcCommonControllerService;
import org.kuali.coeus.sys.framework.gv.GlobalVariableService;
import org.kuali.rice.krad.document.TransactionalDocumentControllerService;
import org.kuali.rice.krad.uif.UifParameters;
import org.kuali.rice.krad.web.form.UifFormBase;
import org.kuali.rice.krad.web.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.servlet.ModelAndView;

public abstract class SapFeedsControllerBase {

	@Autowired
	@Qualifier("kcCommonControllerService")
	private KcCommonControllerService kcCommonControllerService;

	@Autowired
	@Qualifier("transactionalDocumentControllerService")
	private TransactionalDocumentControllerService transactionalDocumentControllerService;

	@Autowired
	@Qualifier("collectionControllerService")
	private CollectionControllerService collectionControllerService;

	@Autowired
	@Qualifier("modelAndViewService")
	private ModelAndViewService modelAndViewService;

	@Autowired
	@Qualifier("navigationControllerService")
	private NavigationControllerService navigationControllerService;

	@Autowired
	@Qualifier("globalVariableService")
	private GlobalVariableService globalVariableService;

	protected UifFormBase createInitialForm(HttpServletRequest request) {
		return new SapFeedsForm();
	}

	@ModelAttribute(value = "KualiForm")
	public UifFormBase initForm(HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		UifFormBase form = getKcCommonControllerService().initForm(
				this.createInitialForm(request), request, response);
		return form;
	}

	protected ModelAndView navigate(SapFeedsForm form) throws Exception {
		form.setPageId(form
				.getActionParamaterValue(UifParameters.NAVIGATE_TO_PAGE_ID));
		form.setDirtyForm(false);

		return getModelAndViewService().getModelAndView(form);
	}

	public KcCommonControllerService getKcCommonControllerService() {
		return kcCommonControllerService;
	}

	public void setKcCommonControllerService(
			KcCommonControllerService kcCommonControllerService) {
		this.kcCommonControllerService = kcCommonControllerService;
	}

	public TransactionalDocumentControllerService getTransactionalDocumentControllerService() {
		return transactionalDocumentControllerService;
	}

	public void setTransactionalDocumentControllerService(
			TransactionalDocumentControllerService transactionalDocumentControllerService) {
		this.transactionalDocumentControllerService = transactionalDocumentControllerService;
	}

	public CollectionControllerService getCollectionControllerService() {
		return collectionControllerService;
	}

	public void setCollectionControllerService(
			CollectionControllerService collectionControllerService) {
		this.collectionControllerService = collectionControllerService;
	}

	public ModelAndViewService getModelAndViewService() {
		return modelAndViewService;
	}

	public void setModelAndViewService(ModelAndViewService modelAndViewService) {
		this.modelAndViewService = modelAndViewService;
	}

	public NavigationControllerService getNavigationControllerService() {
		return navigationControllerService;
	}

	public void setNavigationControllerService(
			NavigationControllerService navigationControllerService) {
		this.navigationControllerService = navigationControllerService;
	}

	protected GlobalVariableService getGlobalVariableService() {
		return globalVariableService;
	}

	public void setGlobalVariableService(
			GlobalVariableService globalVariableService) {
		this.globalVariableService = globalVariableService;
	}
}
