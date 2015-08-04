package edu.mit.kc.dashboard;

import edu.mit.kc.dashboard.bo.DashboardMenuItem;
import org.apache.commons.lang3.StringUtils;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.core.api.criteria.QueryResults;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.service.KRADServiceLocator;
import org.kuali.rice.krad.uif.util.UifKeyValueLocation;
import org.kuali.rice.krad.util.KRADConstants;
import org.kuali.rice.krad.web.service.ControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DashboardMenuService {

    @Autowired
    @Qualifier("dataObjectService")
    private DataObjectService dataObjectService;

    @Autowired
    @Qualifier("kualiConfigurationService")
    private ConfigurationService configurationService;

    protected String appUrl;

    protected static final String APP_URL_TOKEN = "<<APPLICATION_URL>>";

    public List<DashboardMenuItemSuggestion> getActiveMenuItems() throws Exception{

        appUrl = configurationService.getPropertyValueAsString(KRADConstants.APPLICATION_URL_KEY);

        Map<String, Object> criteria = new HashMap<String, Object>();
        criteria.put("active", "Y");

        QueryResults<DashboardMenuItem> menuItems = this.getDataObjectService().findMatching(DashboardMenuItem.class,
                QueryByCriteria.Builder.andAttributes(criteria).build());

        List<DashboardMenuItemSuggestion> suggestions = new ArrayList<>();
        for (DashboardMenuItem item : menuItems.getResults()) {
            suggestions.add(new DashboardMenuItemSuggestion(item));
        }

        return suggestions;
    }

    public class DashboardMenuItemSuggestion {
        private String label;
        private String value;
        private String href;

        public DashboardMenuItemSuggestion (DashboardMenuItem item) throws Exception {
            this.setLabel(item.getMenuItemFormatted());
            this.setValue(item.getMenuItem());

            String href = appUrl + item.getMenuAction().replace(APP_URL_TOKEN, URLEncoder.encode(appUrl, "UTF-8"));
            this.setHref(href);
        }

        public String getLabel() {
            return label;
        }

        public void setLabel(String label) {
            this.label = label;
        }

        public String getValue() {
            return value;
        }

        public void setValue(String value) {
            this.value = value;
        }

        public String getHref() {
            return href;
        }

        public void setHref(String href) {
            this.href = href;
        }
    }

    public DataObjectService getDataObjectService() {
        return dataObjectService;
    }

    public void setDataObjectService(DataObjectService dataObjectService) {
        this.dataObjectService = dataObjectService;
    }
}
