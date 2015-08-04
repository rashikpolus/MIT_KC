/*
 * Copyright 2005-2014 The Kuali Foundation
 * 
 * Licensed under the GNU Affero General Public License, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.opensource.org/licenses/ecl1.php
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package edu.mit.kc.cac;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.kuali.coeus.common.notification.impl.service.KcNotificationService;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.scheduling.quartz.QuartzJobBean;
import org.springframework.transaction.annotation.Transactional;

/**
 * This job is triggered by the quartz scheduler to kick off the CFDA table update.
 * Extends QuartzJobBean for Persistence.
 */
public class CacDataFeedJobDetail extends QuartzJobBean {
    private static final Log LOG = LogFactory.getLog(CacDataFeedJobDetail.class);

    private CacDataFeedService cacDataFeedService;
	private ParameterService parameterService;
    private KcNotificationService kcNotificationService;

    public CacDataFeedService getCacDataFeedService() {
		return cacDataFeedService;
	}

	public void setCacDataFeedService(
			CacDataFeedService cacDataFeedService) {
		this.cacDataFeedService = cacDataFeedService;
	}

    /*
     * This is the method that is called by the Quartz job scheduler.
     */
    @Override
    @Transactional
    protected void executeInternal(JobExecutionContext context) throws JobExecutionException {
    	if(cacDataFeedService==null){
    		cacDataFeedService = KcServiceLocator.getService(CacDataFeedService.class);
    	}
    	cacDataFeedService.parseAndUpdateCac();
    }
    
    /**
     * This is injected into the scheduler context by spring.
     * @param kcNotificationService
     */
    public void setParameterService(ParameterService parameterService) {
        this.parameterService = parameterService;
    }
    
    /**
     * This is injected into the scheduler context by spring.
     * @param kcNotificationService
     */
    public void setKcNotificationService(KcNotificationService kcNotificationService) {
        this.kcNotificationService = kcNotificationService;
    }

    protected ParameterService getParameterService() {
        return parameterService;
    }

    protected KcNotificationService getKcNotificationService() {
        return kcNotificationService;
    }

}
