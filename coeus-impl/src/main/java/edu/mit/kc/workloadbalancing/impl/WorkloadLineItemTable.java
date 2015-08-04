package edu.mit.kc.workloadbalancing.impl;


import java.util.*;

import edu.mit.kc.workloadbalancing.core.WorkloadForm;
import edu.mit.kc.workloadbalancing.util.WorkloadUtils;
import org.apache.commons.beanutils.PropertyUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.kuali.coeus.common.framework.impl.LineItemRow;
import org.kuali.coeus.common.framework.sponsor.hierarchy.SponsorHierarchy;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.krad.datadictionary.parse.BeanTag;
import org.kuali.rice.krad.datadictionary.parse.BeanTagAttribute;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.uif.component.BindingInfo;
import org.kuali.rice.krad.uif.component.DataBinding;
import org.kuali.rice.krad.uif.container.GroupBase;
import org.kuali.rice.krad.uif.lifecycle.ViewLifecycle;
import org.kuali.rice.krad.uif.util.LifecycleElement;
import org.kuali.rice.krad.uif.util.ObjectPropertyUtils;
import org.kuali.rice.krad.uif.view.View;
import edu.mit.kc.workloadbalancing.bo.WorkloadBalancing;


@BeanTag(name = "workloadLineItemTable", parent = "Uif-WorkloadLineItemTable")
public class WorkloadLineItemTable extends GroupBase implements DataBinding {

	private static final long serialVersionUID = 1677312513807050571L;
	private static final Log LOG = LogFactory.getLog(WorkloadLineItemTable.class);

	public static final String HIERARCHY_NAME = "Workload Balancing";

	private String propertyName;
    private String sponsorsPropertyPath = "sponsors";
	private BindingInfo bindingInfo;
	private LineItemRow headerRow;

	private List<SponsorHierarchy> sponsorsUpdated;
	private List<WorkloadBalancing> lineitemrows = new ArrayList<WorkloadBalancing>();

	@Override
	public void performInitialization(Object model) {
		super.performInitialization(model);

		View view = ViewLifecycle.getView();
		bindingInfo.setDefaults(view, getPropertyName());
	}

	/**
	 * {@inheritDoc}
	 * <p/>
	 * Creates the LineItemRows based on the data stored within the property
	 * given by propertyName.
	 */
	@Override
	public void performFinalize(Object model, LifecycleElement parent) {
		super.performFinalize(model, parent);

		try {

			lineitemrows = (List<WorkloadBalancing>) (PropertyUtils
					.getProperty(model, this.getBindingInfo().getBindingPath()));

            Collections.sort(lineitemrows, new Comparator<WorkloadBalancing>() {
                @Override
                public int compare(WorkloadBalancing wl1, WorkloadBalancing wl2) {
                    return wl1.getPersonName().compareTo(wl2.getPersonName());
                }
            });

			HashMap<String, String> sponsorGroup = new HashMap<String, String>();
			sponsorGroup.put("hierarchyName", HIERARCHY_NAME);

			List<String> sponsors = ObjectPropertyUtils.getPropertyValue(model, sponsorsPropertyPath);

			headerRow = new LineItemRow();
			headerRow.getCellContent().add("Contract Administrator");
			headerRow.getCellContent().add("Capacity");


			for (String sponsor : sponsors) {
            	headerRow.getCellContent().add(WorkloadUtils.formatSponsorName(sponsor));
			}

		} catch (Exception e) {
			LOG.error(
					"Exception occurred while trying to get value for WorkloadLineItemTable: "
							+ this, e);
		}
	}

	@BeanTagAttribute
	public String getPropertyName() {
		return propertyName;
	}

	public void setPropertyName(String propertyName) {
		this.propertyName = propertyName;
	}

    public String getSponsorsPropertyPath() {
        return sponsorsPropertyPath;
    }

    public void setSponsorsPropertyPath(String sponsorsPropertyPath) {
        this.sponsorsPropertyPath = sponsorsPropertyPath;
    }

    @BeanTagAttribute
	public BindingInfo getBindingInfo() {
		return bindingInfo;
	}

	public void setBindingInfo(BindingInfo bindingInfo) {
		this.bindingInfo = bindingInfo;
	}

	public LineItemRow getHeaderRow() {
		return headerRow;
	}

	public List<WorkloadBalancing> getLineitemrows() {
		return lineitemrows;
	}

	public void setLineitemrows(List<WorkloadBalancing> lineitemrows) {
		this.lineitemrows = lineitemrows;
	}

}
