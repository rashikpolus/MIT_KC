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
package org.kuali.coeus.propdev.impl.budget.nonpersonnel;


import java.sql.Date;

import org.apache.commons.beanutils.PropertyUtils;
import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.common.budget.framework.core.Budget;
import org.kuali.coeus.common.budget.framework.core.BudgetConstants;
import org.kuali.coeus.common.budget.framework.core.BudgetSaveEvent;
import org.kuali.coeus.common.budget.framework.nonpersonnel.ApplyToPeriodsBudgetEvent;
import org.kuali.coeus.common.budget.framework.nonpersonnel.BudgetDirectCostLimitEvent;
import org.kuali.coeus.common.budget.framework.nonpersonnel.BudgetFormulatedCostDetail;
import org.kuali.coeus.common.budget.framework.nonpersonnel.BudgetLineItem;
import org.kuali.coeus.common.budget.framework.nonpersonnel.BudgetPeriodCostLimitEvent;
import org.kuali.coeus.common.budget.framework.period.BudgetPeriod;
import org.kuali.coeus.common.budget.framework.personnel.BudgetAddPersonnelPeriodEvent;
import org.kuali.coeus.common.budget.framework.personnel.BudgetPersonnelDetails;
import org.kuali.coeus.common.budget.framework.personnel.BudgetSavePersonnelEvent;
import org.kuali.coeus.common.budget.framework.nonpersonnel.*;
import org.kuali.coeus.common.budget.framework.period.BudgetPeriod;
import org.kuali.coeus.common.budget.framework.rate.BudgetRatesService;
import org.kuali.coeus.common.budget.impl.nonpersonnel.BudgetExpensesRuleEvent;
import org.kuali.coeus.propdev.impl.budget.core.ProposalBudgetConstants;
import org.kuali.coeus.propdev.impl.budget.core.ProposalBudgetControllerBase;
import org.kuali.coeus.propdev.impl.budget.core.ProposalBudgetForm;
import org.kuali.coeus.sys.api.model.ScaleTwoDecimal;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.rice.krad.uif.UifConstants;
import org.kuali.rice.krad.uif.UifParameters;
import org.kuali.rice.krad.web.form.DialogResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping(value = "/proposalBudget")
public class ProposalBudgetPeriodProjectCostController extends ProposalBudgetControllerBase {

	private static final String EDIT_NONPERSONNEL_PERIOD_DIALOG_ID = "PropBudget-NonPersonnelCostsPage-EditNonPersonnel-Dialog";
	private static final String EDIT_NONPERSONNEL_PARTICIPANT_DIALOG_ID = "PropBudget-NonPersonnelCostsPage-EditParticipantSupport-Dialog";
	protected static final String CONFIRM_PERIOD_CHANGES_DIALOG_ID = "PropBudget-ConfirmPeriodChangesDialog";
	protected static final String ADD_NONPERSONNEL_PERIOD_DIALOG_ID = "PropBudget-NonPersonnelCostsPage-AddNonPersonnel-Dialog";
	protected static final String CONFIRM_SYNC_TO_PERIOD_COST_LIMIT_DIALOG_ID = "PropBudget-NonPersonnelCosts-SyncToPeriodCostLimit";
	protected static final String CONFIRM_SYNC_TO_DIRECT_COST_LIMIT_DIALOG_ID = "PropBudget-NonPersonnelCosts-SyncToDirectCostLimit";
	
	protected static final String ADD_NONPERSONNEL_PERIOD_DIALOG_ID_SEP = "PropBudget-SinglePointEntryPage-AddNonPersonnel-Dialog";
	
	private static final String EDIT_NONPERSONNEL_PERIOD_DIALOG_ID_SPE= "PropBudget-SinglePointEntryPage-EditNonPersonnel-Dialog";
	private static final String EDIT_NONPERSONNEL_PARTICIPANT_DIALOG_ID_SEP = "PropBudget-SinglePointEntryPage-EditParticipantSupport-Dialog";
	
	private boolean budgetSinglePointEntry = false;
	
	public static final String NEW_FORMULATED_COST = "addProjectBudgetLineItemHelper.budgetLineItem.budgetFormulatedCosts";

	@Autowired
	@Qualifier("budgetRatesService")
	private BudgetRatesService budgetRatesService;

	@Transactional @RequestMapping(params="methodToCall=assignLineItemToPeriod")
	public ModelAndView assignLineItemToPeriod(@RequestParam("budgetPeriodId") String budgetPeriodId, @ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		ModelAndView modelAndView = getModelAndViewService().getModelAndView(form);
		Budget budget = form.getBudget();
        Long currentTabBudgetPeriodId = Long.parseLong(budgetPeriodId);
		BudgetPeriod budgetPeriod = getBudgetPeriod(currentTabBudgetPeriodId, budget);
        DialogResponse dialogResponse = form.getDialogResponse(ProposalBudgetConstants.KradConstants.CONFIRM_PERIOD_CHANGES_DIALOG_ID);
        if(dialogResponse == null && budgetPeriod.getBudgetPeriod() > 1 && !isBudgetLineItemExists(budget)) {
        	modelAndView = getModelAndViewService().showDialog(ProposalBudgetConstants.KradConstants.CONFIRM_PERIOD_CHANGES_DIALOG_ID, true, form);
        }else {
            boolean confirmResetDefault = dialogResponse == null ? true : dialogResponse.getResponseAsBoolean();
            if(confirmResetDefault) {
        		form.getAddProjectBudgetLineItemHelper().reset();
        		form.getAddProjectBudgetLineItemHelper().setCurrentTabBudgetPeriod(budgetPeriod);
        		modelAndView = getModelAndViewService().showDialog(ProposalBudgetConstants.KradConstants.ADD_NONPERSONNEL_PERIOD_DIALOG_ID, true, form);
             }
        }
 		return modelAndView;
	}

	@Transactional @RequestMapping(params="methodToCall=addSPELineItemToPeriod")
	public ModelAndView addSPELineItemToPeriod(@RequestParam("budgetPeriod") String budgetPeriod, @ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		setBudgetSinglePointEntry(true);
		int budgetPeriodIndex = Integer.parseInt(budgetPeriod) - 1;
		String newLineItemPath = "budget.budgetPeriods_" + budgetPeriodIndex + "_.budgetLineItems";
		Budget budget = form.getBudget();
        BudgetLineItem newBudgetLineItem = ((BudgetLineItem)form.getNewCollectionLines().get(newLineItemPath));
        Date lineItemStartDate = newBudgetLineItem.getStartDate();
        Date lineItemEndDate = newBudgetLineItem.getEndDate();
		newBudgetLineItem.setBudget(budget);
		BudgetPeriod currentTabBudgetPeriod = budget.getBudgetPeriods().get(budgetPeriodIndex);
        getBudgetService().populateNewBudgetLineItem(newBudgetLineItem, currentTabBudgetPeriod);
        newBudgetLineItem.setStartDate(lineItemStartDate);
        newBudgetLineItem.setEndDate(lineItemEndDate);
        boolean rulePassed = isValidBudgetLineItem(budget, newBudgetLineItem, currentTabBudgetPeriod, "newCollectionLines['budget.budgetPeriods_0_.budgetLineItems']");
        if(rulePassed) {
            getBudgetCalculationService().populateCalculatedAmount(budget, newBudgetLineItem);
            getBudgetService().recalculateBudgetPeriod(budget, currentTabBudgetPeriod);
            getCollectionControllerService().addLine(form);
            getDataObjectService().save(budget);
    	    validateBudgetExpenses(budget, currentTabBudgetPeriod);
            form.setAjaxReturnType("update-page");
        }
        return getModelAndViewService().getModelAndView(form);
	}
	
	protected boolean isValidBudgetLineItem(Budget budget, BudgetLineItem newBudgetLineItem, BudgetPeriod budgetPeriod, String errorPath) {
        boolean rulePassed = true;
        if(isPersonnelLineItem(newBudgetLineItem)) {
        	BudgetPersonnelDetails newBudgetPersonnelDetail = getNewPersonnelLineItem(budget, budgetPeriod, newBudgetLineItem);
        	rulePassed &= getKcBusinessRulesEngine().applyRules(new BudgetAddPersonnelPeriodEvent(budget, budgetPeriod, newBudgetLineItem, newBudgetPersonnelDetail,
                    errorPath, "costElement"));
        }else {
        	rulePassed = isSaveBudgetLineItemRulePassed(budget, budgetPeriod, newBudgetLineItem, errorPath);
        }
		return rulePassed;
	}
	
	protected BudgetPersonnelDetails getNewPersonnelLineItem(Budget budget, BudgetPeriod budgetPeriod, BudgetLineItem newBudgetLineItem) {
		BudgetPersonnelDetails newBudgetPersonnelDetail = new BudgetPersonnelDetails();
		newBudgetPersonnelDetail.setPersonSequenceNumber(BudgetConstants.BudgetPerson.SUMMARYPERSON.getPersonSequenceNumber());
		newBudgetPersonnelDetail.setStartDate(newBudgetLineItem.getStartDate());
		newBudgetPersonnelDetail.setEndDate(newBudgetLineItem.getEndDate());
		newBudgetPersonnelDetail.setBudgetLineItem(newBudgetLineItem);
		return newBudgetPersonnelDetail;
	}
	
	protected boolean isPersonnelLineItem(BudgetLineItem budgetLineItem) {
		String personnelBudgetCategoryTypeCode = getBudgetCalculationService().getPersonnelBudgetCategoryTypeCode();
		refreshCostElement(budgetLineItem);
		return budgetLineItem.getBudgetCategory().getBudgetCategoryTypeCode().equalsIgnoreCase(personnelBudgetCategoryTypeCode);
	}

	@Transactional @RequestMapping(params="methodToCall=addLineItemToPeriod")
	public ModelAndView addLineItemToPeriod(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		Budget budget = form.getBudget();
		BudgetPeriod currentTabBudgetPeriod = form.getAddProjectBudgetLineItemHelper().getCurrentTabBudgetPeriod();
		BudgetLineItem newBudgetLineItem = form.getAddProjectBudgetLineItemHelper().getBudgetLineItem();
		newBudgetLineItem.setBudget(budget);
        getBudgetService().populateNewBudgetLineItem(newBudgetLineItem, currentTabBudgetPeriod);
        getBudgetCalculationService().populateCalculatedAmount(budget, newBudgetLineItem);
        currentTabBudgetPeriod.getBudgetLineItems().add(newBudgetLineItem);
        getBudgetService().recalculateBudgetPeriod(budget, currentTabBudgetPeriod);
        getDataObjectService().save(budget);
		form.getAddProjectBudgetLineItemHelper().reset();
	    validateBudgetExpenses(budget, currentTabBudgetPeriod);
		return getModelAndViewService().getModelAndView(form);
	}

	@Transactional @RequestMapping(params="methodToCall=editNonPersonnelPeriodDetails")
	public ModelAndView editNonPersonnelPeriodDetails(@RequestParam("budgetPeriodId") String budgetPeriodId, @ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
	    Budget budget = form.getBudget();
	    String selectedLine = form.getActionParamaterValue(UifParameters.SELECTED_LINE_INDEX);
        if (StringUtils.isNotEmpty(selectedLine)) {
		    Long currentTabBudgetPeriodId = Long.parseLong(budgetPeriodId);
		    BudgetPeriod budgetPeriod = getBudgetPeriod(currentTabBudgetPeriodId, budget);
        	form.getAddProjectBudgetLineItemHelper().reset();
        	BudgetLineItem editBudgetLineItem = form.getBudget().getBudgetLineItems().get(Integer.parseInt(selectedLine));
        	String editLineIndex = Integer.toString(budgetPeriod.getBudgetLineItems().indexOf(editBudgetLineItem));
		    form.getAddProjectBudgetLineItemHelper().setBudgetLineItem(getDataObjectService().copyInstance(editBudgetLineItem));
		    form.getAddProjectBudgetLineItemHelper().setEditLineIndex(editLineIndex);
		    form.getAddProjectBudgetLineItemHelper().setCurrentTabBudgetPeriod(budgetPeriod);
		    form.getAddProjectBudgetLineItemHelper().setBudgetCategoryTypeCode(editBudgetLineItem.getBudgetCategory().getBudgetCategoryTypeCode());
	    }
    	return getModelAndViewService().showDialog(ProposalBudgetConstants.KradConstants.EDIT_NONPERSONNEL_PERIOD_DIALOG_ID, true, form);
	}
	@Transactional @RequestMapping(params="methodToCall=editSPELineItemDetails")
	public ModelAndView editSPELineItemDetails(@RequestParam("budgetPeriodId") String budgetPeriodId, @ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
	    Budget budget = form.getBudget();
	    String selectedLine = form.getActionParamaterValue(UifParameters.SELECTED_LINE_INDEX);
        if (StringUtils.isNotEmpty(selectedLine)) {
		    Long currentTabBudgetPeriodId = Long.parseLong(budgetPeriodId);
		    BudgetPeriod budgetPeriod = getBudgetPeriod(currentTabBudgetPeriodId, budget);
        	form.getAddProjectBudgetLineItemHelper().reset();
        	BudgetLineItem editBudgetLineItem = budgetPeriod.getBudgetLineItems().get(Integer.parseInt(selectedLine));
        	String editLineIndex = Integer.toString(budgetPeriod.getBudgetLineItems().indexOf(editBudgetLineItem));
 		    form.getAddProjectBudgetLineItemHelper().setBudgetLineItem(getDataObjectService().copyInstance(editBudgetLineItem));
		    form.getAddProjectBudgetLineItemHelper().setEditLineIndex(editLineIndex);
		    form.getAddProjectBudgetLineItemHelper().setCurrentTabBudgetPeriod(budgetPeriod);
	    }
    	return getModelAndViewService().showDialog(EDIT_NONPERSONNEL_PERIOD_DIALOG_ID_SPE, true, form);
	}

    @Transactional @RequestMapping(params={"methodToCall=refresh", "refreshCaller=PropBudget-EditNonPersonnelPeriod-Section"})
    public ModelAndView refreshNonPersonnelPeriodDetails(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
        form.setAjaxReturnType(UifConstants.AjaxReturnTypes.UPDATECOMPONENT.getKey());
        form.setUpdateComponentId("PropBudget-EditNonPersonnelPeriod-Section");
        getDataObjectService().wrap(form.getAddProjectBudgetLineItemHelper().getBudgetLineItem()).fetchRelationship("costElementBO");
        return getRefreshControllerService().refresh(form);
    }

	@Transactional @RequestMapping(params="methodToCall=deleteBudgetLineItem")
	public ModelAndView deleteBudgetLineItem(@RequestParam("budgetPeriodId") String budgetPeriodId, @ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
	    Budget budget = form.getBudget();
	    String selectedLine = form.getActionParamaterValue(UifParameters.SELECTED_LINE_INDEX);
        if (StringUtils.isNotEmpty(selectedLine)) {
        	BudgetLineItem deletedBudgetLineItem = form.getBudget().getBudgetLineItems().get(Integer.parseInt(selectedLine));
		    Long currentTabBudgetPeriodId = Long.parseLong(budgetPeriodId);
		    BudgetPeriod budgetPeriod = getBudgetPeriod(currentTabBudgetPeriodId, budget);
		    budgetPeriod.getBudgetLineItems().remove(deletedBudgetLineItem);
		    validateBudgetExpenses(budget, budgetPeriod);
		    form.setAjaxReturnType("update-page");
	    }
		return getModelAndViewService().getModelAndView(form);
	}
	
	@Transactional @RequestMapping(params="methodToCall=deleteSPEBudgetLineItem")
	public ModelAndView deleteSPEBudgetLineItem(@RequestParam("budgetPeriodId") String budgetPeriodId, @ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
	    Budget budget = form.getBudget();
	    String selectedLine = form.getActionParamaterValue(UifParameters.SELECTED_LINE_INDEX);
        if (StringUtils.isNotEmpty(selectedLine)) {
		    Long currentTabBudgetPeriodId = Long.parseLong(budgetPeriodId);
		    BudgetPeriod budgetPeriod = getBudgetPeriod(currentTabBudgetPeriodId, budget);
        	BudgetLineItem deletedBudgetLineItem = budgetPeriod.getBudgetLineItems().get(Integer.parseInt(selectedLine));
		    budgetPeriod.getBudgetLineItems().remove(deletedBudgetLineItem);
		    validateBudgetExpenses(budget, budgetPeriod);
		    form.setAjaxReturnType("update-page");
	    }
		return getModelAndViewService().getModelAndView(form);
	}
	
	@Transactional @RequestMapping(params="methodToCall=saveBudgetLineItem")
	public ModelAndView saveBudgetLineItem(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		saveBudgetPeriodLineItem(form);
		return getModelAndViewService().getModelAndView(form);
	}
	
	protected void saveBudgetPeriodLineItem(ProposalBudgetForm form) {
	    setEditedBudgetLineItem(form);
	    Budget budget = form.getBudget();
	    BudgetPeriod budgetPeriod = form.getAddProjectBudgetLineItemHelper().getCurrentTabBudgetPeriod();
	    validateBudgetExpenses(budget, budgetPeriod);
	}
	
	@Transactional @RequestMapping(params="methodToCall=saveSPEBudgetLineItem")
	public ModelAndView saveSPEBudgetLineItem(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		Budget budget = form.getBudget();
		BudgetPeriod budgetPeriod = form.getAddProjectBudgetLineItemHelper().getCurrentTabBudgetPeriod();
		BudgetLineItem budgetLineItem = form.getAddProjectBudgetLineItemHelper().getBudgetLineItem();
		boolean rulePassed = getKcBusinessRulesEngine().applyRules(new BudgetSavePersonnelEvent(budget, budgetPeriod));
        rulePassed &= getKcBusinessRulesEngine().applyRules(new BudgetSaveEvent(budget));
       	rulePassed &= isSaveBudgetLineItemRulePassed(budget, budgetPeriod, budgetLineItem, "addProjectPersonnelHelper.budgetLineItem.");
        if(rulePassed) {
        	saveBudgetPeriodLineItem(form);
        }
		return getModelAndViewService().getModelAndView(form);
	}

	protected void validateBudgetExpenses(Budget budget, BudgetPeriod budgetPeriod) {
	    getBudgetCalculationService().calculateBudgetPeriod(budget, budgetPeriod);
	    String errorPath = BudgetConstants.BudgetAuditRules.NON_PERSONNEL_COSTS.getPageId();
	    if(budgetSinglePointEntry) {
	    	errorPath = BudgetConstants.BudgetAuditRules.SPE_LINEITEM_COSTS.getPageId();
	    }
		getKcBusinessRulesEngine().applyRules(new BudgetExpensesRuleEvent(budget, errorPath));
	}

	@Transactional @RequestMapping(params="methodToCall=saveAndApplyToLaterPeriods")
	public ModelAndView saveAndApplyToLaterPeriods(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		Budget budget = form.getBudget();
		BudgetPeriod currentTabBudgetPeriod = form.getAddProjectBudgetLineItemHelper().getCurrentTabBudgetPeriod();
	    BudgetLineItem budgetLineItem = form.getAddProjectBudgetLineItemHelper().getBudgetLineItem();
	    setEditedBudgetLineItem(form);
	    getBudgetCalculationService().applyToLaterPeriods(budget,currentTabBudgetPeriod,budgetLineItem);
	    validateBudgetExpenses(budget, currentTabBudgetPeriod);
		return super.save(form);
	}

	private void setEditedBudgetLineItem(ProposalBudgetForm form) {
	    BudgetLineItem budgetLineItem = form.getAddProjectBudgetLineItemHelper().getBudgetLineItem();
	    BudgetPeriod budgetPeriod = form.getAddProjectBudgetLineItemHelper().getCurrentTabBudgetPeriod();
	    setLineItemBudgetCategory(budgetLineItem);
	    int editLineIndex = Integer.parseInt(form.getAddProjectBudgetLineItemHelper().getEditLineIndex());
		BudgetLineItem newBudgetLineItem = getDataObjectService().save(budgetLineItem);
		budgetPeriod.getBudgetLineItems().set(editLineIndex, newBudgetLineItem);
	}

	@Transactional @RequestMapping(params="methodToCall=syncToPeriodCostDirectLimit")
	public ModelAndView syncToPeriodCostDirectLimit(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		Budget budget = form.getBudget();
		BudgetPeriod currentTabBudgetPeriod = form.getAddProjectBudgetLineItemHelper().getCurrentTabBudgetPeriod();
	    int editLineIndex = Integer.parseInt(form.getAddProjectBudgetLineItemHelper().getEditLineIndex());
    	BudgetLineItem budgetLineItem = currentTabBudgetPeriod.getBudgetLineItems().get(editLineIndex);
        DialogResponse dialogResponse = form.getDialogResponse(ProposalBudgetConstants.KradConstants.CONFIRM_SYNC_TO_DIRECT_COST_LIMIT_DIALOG_ID);
        if(dialogResponse == null && currentTabBudgetPeriod.getTotalDirectCost().isGreaterThan(currentTabBudgetPeriod.getDirectCostLimit())) {
        	return getModelAndViewService().showDialog(ProposalBudgetConstants.KradConstants.CONFIRM_SYNC_TO_DIRECT_COST_LIMIT_DIALOG_ID, true, form);
        }else {
            boolean confirmResetDefault = dialogResponse == null ? true : dialogResponse.getResponseAsBoolean();
            if(confirmResetDefault) {
        	    BudgetLineItem editedBudgetLineItem = form.getAddProjectBudgetLineItemHelper().getBudgetLineItem();
        	    editedBudgetLineItem.setLineItemCost(budgetLineItem.getLineItemCost());
            	boolean rulePassed = getKcBusinessRulesEngine().applyRules(new ApplyToPeriodsBudgetEvent(budget, "addProjectBudgetLineItemHelper.budgetLineItem.", editedBudgetLineItem,
            			currentTabBudgetPeriod));
            	rulePassed &= getKcBusinessRulesEngine().applyRules(new BudgetDirectCostLimitEvent(budget, currentTabBudgetPeriod, editedBudgetLineItem,
            			"addProjectBudgetLineItemHelper.budgetLineItem."));
            	if(rulePassed) {
                    boolean syncComplete = getBudgetCalculationService().syncToPeriodDirectCostLimit(budget, currentTabBudgetPeriod, editedBudgetLineItem);
                    if(!syncComplete) {
                    	getGlobalVariableService().getMessageMap().putError("addProjectBudgetLineItemHelper.budgetLineItem.lineItemCost",
                    			KeyConstants.INSUFFICIENT_AMOUNT_TO_PERIOD_DIRECT_COST_LIMIT_SYNC);
                    }
            	}
            }
        }
		return getModelAndViewService().getModelAndView(form);
	}

	@Transactional @RequestMapping(params="methodToCall=syncToPeriodCostLimit")
	public ModelAndView syncToPeriodCostLimit(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		Budget budget = form.getBudget();
		BudgetPeriod currentTabBudgetPeriod = form.getAddProjectBudgetLineItemHelper().getCurrentTabBudgetPeriod();
	    int editLineIndex = Integer.parseInt(form.getAddProjectBudgetLineItemHelper().getEditLineIndex());
    	BudgetLineItem budgetLineItem = currentTabBudgetPeriod.getBudgetLineItems().get(editLineIndex);
        DialogResponse dialogResponse = form.getDialogResponse(ProposalBudgetConstants.KradConstants.CONFIRM_SYNC_TO_PERIOD_COST_LIMIT_DIALOG_ID);
        if(dialogResponse == null && currentTabBudgetPeriod.getTotalCost().isGreaterThan(currentTabBudgetPeriod.getTotalCostLimit())) {
        	return getModelAndViewService().showDialog(ProposalBudgetConstants.KradConstants.CONFIRM_SYNC_TO_PERIOD_COST_LIMIT_DIALOG_ID, true, form);
        }else {
            boolean confirmResetDefault = dialogResponse == null ? true : dialogResponse.getResponseAsBoolean();
            if(confirmResetDefault) {
        	    BudgetLineItem editedBudgetLineItem = form.getAddProjectBudgetLineItemHelper().getBudgetLineItem();
        	    editedBudgetLineItem.setLineItemCost(budgetLineItem.getLineItemCost());
            	boolean rulePassed = getKcBusinessRulesEngine().applyRules(new ApplyToPeriodsBudgetEvent(budget, "addProjectBudgetLineItemHelper.budgetLineItem.", editedBudgetLineItem,
            			currentTabBudgetPeriod));
            	rulePassed &= getKcBusinessRulesEngine().applyRules(new BudgetPeriodCostLimitEvent(budget, currentTabBudgetPeriod, editedBudgetLineItem,
            			"addProjectBudgetLineItemHelper.budgetLineItem."));
            	if(rulePassed) {
                    boolean syncComplete = getBudgetCalculationService().syncToPeriodCostLimit(budget, currentTabBudgetPeriod, editedBudgetLineItem);
                    if(!syncComplete) {
                    	getGlobalVariableService().getMessageMap().putError("addProjectBudgetLineItemHelper.budgetLineItem.lineItemCost",
                    			KeyConstants.INSUFFICIENT_AMOUNT_TO_SYNC);
                    }
            	}
            }
        }
 		return getModelAndViewService().getModelAndView(form);
	}

	@Transactional @RequestMapping(params="methodToCall=editParticipantDetails")
	public ModelAndView editParticipantDetails(@RequestParam("budgetPeriodId") String budgetPeriodId, @ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		Budget budget = form.getBudget();
	    Long currentTabBudgetPeriodId = Long.parseLong(budgetPeriodId);
		BudgetPeriod currentTabBudgetPeriod = getBudgetPeriod(currentTabBudgetPeriodId, budget);
	    form.getAddProjectBudgetLineItemHelper().setCurrentTabBudgetPeriod(currentTabBudgetPeriod);
	    String editLineIndex = Integer.toString(budget.getBudgetPeriods().indexOf(currentTabBudgetPeriod));
	    form.getAddProjectBudgetLineItemHelper().setEditLineIndex(editLineIndex);
    	return getModelAndViewService().showDialog(ProposalBudgetConstants.KradConstants.EDIT_NONPERSONNEL_PARTICIPANT_DIALOG_ID, true, form);
	}
	@Transactional @RequestMapping(params="methodToCall=editSEPParticipantDetails")
	public ModelAndView editSEPParticipantDetails(@RequestParam("budgetPeriodId") String budgetPeriodId, @ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		Budget budget = form.getBudget();
	    Long currentTabBudgetPeriodId = Long.parseLong(budgetPeriodId);
		BudgetPeriod currentTabBudgetPeriod = getBudgetPeriod(currentTabBudgetPeriodId, budget);
	    form.getAddProjectBudgetLineItemHelper().setCurrentTabBudgetPeriod(currentTabBudgetPeriod);
	    String editLineIndex = Integer.toString(budget.getBudgetPeriods().indexOf(currentTabBudgetPeriod));
	    form.getAddProjectBudgetLineItemHelper().setEditLineIndex(editLineIndex);
    	return getModelAndViewService().showDialog(EDIT_NONPERSONNEL_PARTICIPANT_DIALOG_ID_SEP, true, form);
	}
	
	@Transactional @RequestMapping(params="methodToCall=saveParticipantDetails")
	public ModelAndView saveParticipantDetails(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		BudgetPeriod currentTabBudgetPeriod = form.getAddProjectBudgetLineItemHelper().getCurrentTabBudgetPeriod();
		getDataObjectService().save(currentTabBudgetPeriod);
 		return getModelAndViewService().getModelAndView(form);
	}

	private BudgetPeriod getBudgetPeriod(Long currentTabBudgetPeriodId, Budget budget) {
        for(BudgetPeriod budgetPeriod : budget.getBudgetPeriods()) {
        	if(budgetPeriod.getBudgetPeriodId().equals(currentTabBudgetPeriodId)) {
        		return budgetPeriod;
        	}
        }
        return null;
	}

	private void setLineItemBudgetCategory(BudgetLineItem budgetLineItem) {
		if (budgetCategoryChanged(budgetLineItem)) {
			getDataObjectService().wrap(budgetLineItem).fetchRelationship("budgetCategory");
			budgetLineItem.getCostElementBO().setBudgetCategory(budgetLineItem.getBudgetCategory());
			budgetLineItem.getCostElementBO().setBudgetCategoryCode(budgetLineItem.getBudgetCategoryCode());
		} else if (costElementChanged(budgetLineItem)) {
			refreshCostElement(budgetLineItem);
		}
		//if both changed then one has to win because the category code is in multiple places
	}

	protected boolean budgetCategoryChanged(BudgetLineItem budgetLineItem) {
		return !budgetLineItem.getBudgetCategoryCode().equals(budgetLineItem.getBudgetCategory().getCode());
	}

	private boolean isBudgetLineItemExists(Budget budget) {
		boolean lineItemExists = false;
		for(BudgetPeriod budgetPeriod : budget.getBudgetPeriods()) {
			if(budgetPeriod.getBudgetPeriod() > 1 && budgetPeriod.getBudgetLineItems().size() > 0) {
				lineItemExists = true;
				break;
			}
		}
		return lineItemExists;
	}

	@Transactional @RequestMapping(params="methodToCall=addFormulatedCost")
	public ModelAndView addFormulatedCost(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
	    getCollectionControllerService().addLine(form);
		calculateAndUpdateFormulatedCost(form);
        return getModelAndViewService().getModelAndView(form);
	}

	@Transactional @RequestMapping(params="methodToCall=updateFormulatedCost")
	public ModelAndView updateFormulatedCost(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		String formulateCostIndex = form.getAddProjectBudgetLineItemHelper().getBudgetFormulatedCostIndex();
		form.getAddProjectBudgetLineItemHelper().getBudgetLineItem().getBudgetFormulatedCosts().set(
				Integer.parseInt(formulateCostIndex), form.getAddProjectBudgetLineItemHelper().getBudgetFormulatedCostDetail());
		calculateAndUpdateFormulatedCost(form);
        return getModelAndViewService().getModelAndView(form);
	}

	@Transactional @RequestMapping(params="methodToCall=deleteFormulatedCost")
	public ModelAndView deleteFormulatedCost(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
	    DialogResponse dialogResponse = form.getDialogResponse(ProposalBudgetConstants.KradConstants.PROP_BUDGET_FORMULATED_COST_DELETE_CONFIRM);
		if (dialogResponse == null) {
			return getModelAndViewService().showDialog(ProposalBudgetConstants.KradConstants.PROP_BUDGET_FORMULATED_COST_DELETE_CONFIRM,false,form);
		} else if (dialogResponse.getResponseAsBoolean()) {
			getCollectionControllerService().deleteLine(form);
			calculateAndUpdateFormulatedCost(form);
		}
        return getModelAndViewService().getModelAndView(form);
	}
	
	@Transactional @RequestMapping(params="methodToCall=refreshFormulatedUnitCost")
	public ModelAndView refreshFormulatedUnitCost(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		String newLineItemPath = "addProjectBudgetLineItemHelper.budgetLineItem.budgetFormulatedCosts";
		BudgetFormulatedCostDetail newBudgetFormulatedCostDetail = ((BudgetFormulatedCostDetail)form.getNewCollectionLines().get(newLineItemPath));
		String leadUnitNumber = form.getBudget().getDevelopmentProposal().getOwnedByUnitNumber();
		String formulatedType = newBudgetFormulatedCostDetail.getFormulatedTypeCode();
		ScaleTwoDecimal unitCost = getBudgetRatesService().getUnitFormulatedCost(leadUnitNumber, formulatedType);
		newBudgetFormulatedCostDetail.setUnitCost(unitCost);
		return getModelAndViewService().getModelAndView(form);
	}
	
	protected void calculateAndUpdateFormulatedCost(ProposalBudgetForm form) {
	    BudgetLineItem budgetLineItem = form.getAddProjectBudgetLineItemHelper().getBudgetLineItem();
	    getBudgetCalculationService().calculateAndUpdateFormulatedCost(budgetLineItem);
		Budget budget = form.getBudget();
		BudgetPeriod currentTabBudgetPeriod = form.getAddProjectBudgetLineItemHelper().getCurrentTabBudgetPeriod();
        getBudgetService().recalculateBudgetPeriod(budget, currentTabBudgetPeriod);
	}

    @ResponseBody
	@Transactional @RequestMapping(params="methodToCall=resetEditLineItem")
	public void resetEditLineItem(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		form.getAddProjectBudgetLineItemHelper().reset();
	}
	
	public boolean isBudgetSinglePointEntry() {
		return budgetSinglePointEntry;
	}
	public void setBudgetSinglePointEntry(boolean budgetSinglePointEntry) {
		this.budgetSinglePointEntry = budgetSinglePointEntry;
	}

	@Transactional
		 @RequestMapping(params = "methodToCall=setAddUnitFormulatedCost")
		 public ModelAndView setUnitFormulatedCost(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		BudgetFormulatedCostDetail budgetFormulatedCostDetail = (BudgetFormulatedCostDetail) form.getNewCollectionLines().get(NEW_FORMULATED_COST);
		return setUnitFormulatedCost(form, budgetFormulatedCostDetail);
	}

	@Transactional
	@RequestMapping(params = "methodToCall=setEditUnitFormulatedCost")
	public ModelAndView setEditUnitFormulatedCost(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		BudgetFormulatedCostDetail budgetFormulatedCostDetail = form.getAddProjectBudgetLineItemHelper().getBudgetFormulatedCostDetail();
		return setUnitFormulatedCost(form,budgetFormulatedCostDetail);
	}

	protected ModelAndView setUnitFormulatedCost(ProposalBudgetForm form, BudgetFormulatedCostDetail  budgetFormulatedCostDetail) {
		ScaleTwoDecimal unitCost = getBudgetRatesService().getUnitFormulatedCost(
				form.getBudget().getDevelopmentProposal().getUnitNumber(), budgetFormulatedCostDetail.getFormulatedTypeCode());
		budgetFormulatedCostDetail.setUnitCost(unitCost);
		return getRefreshControllerService().refresh(form);
	}

	@Transactional
	@RequestMapping(params = "methodToCall=displayEditFormulatedCost")
	public ModelAndView displayEditFormulatedCost(@ModelAttribute("KualiForm") ProposalBudgetForm form) throws Exception {
		String selectedLine = form.getActionParamaterValue(UifParameters.SELECTED_LINE_INDEX);
		form.getAddProjectBudgetLineItemHelper().setBudgetFormulatedCostIndex(selectedLine);
		BudgetFormulatedCostDetail budgetFormulatedCostDetail = form.getAddProjectBudgetLineItemHelper().getBudgetLineItem().getBudgetFormulatedCosts().get(Integer.parseInt(selectedLine));
		BudgetFormulatedCostDetail tmpBudgetFormulatedCostDetail = new BudgetFormulatedCostDetail();
		PropertyUtils.copyProperties(tmpBudgetFormulatedCostDetail,budgetFormulatedCostDetail);
		form.getAddProjectBudgetLineItemHelper().setBudgetFormulatedCostDetail(tmpBudgetFormulatedCostDetail);
		return getModelAndViewService().showDialog(ProposalBudgetConstants.KradConstants.PROP_BUDGET_FORMULATED_COST_EDIT_DETAILS, true, form);
	}

	public BudgetRatesService getBudgetRatesService() {
		return budgetRatesService;
	}

	public void setBudgetRatesService(BudgetRatesService budgetRatesService) {
		this.budgetRatesService = budgetRatesService;
	}
}
