package edu.mit.kc.header;

import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.kim.api.group.Group;
import org.kuali.rice.kim.api.group.GroupService;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component
public class MitHeaderHelper {

    @Autowired
    @Qualifier("dataObjectService")
    private DataObjectService dataObjectService;

    public static boolean renderMaintenanceHeaderLink() {
        if (GlobalVariables.getUserSession() == null || GlobalVariables.getUserSession().getPerson() == null) {
            return false;
        }

        //TODO determine groups able to see link
        Person currentUser = GlobalVariables.getUserSession().getPerson();
        return true;
    }

    public static boolean renderSysAdminHeaderLink() {
        if (GlobalVariables.getUserSession() == null || GlobalVariables.getUserSession().getPerson() == null) {
            return false;
        }

        //TODO determine groups able to see link
        Person currentUser = GlobalVariables.getUserSession().getPerson();
        
		GroupService groupService = KcServiceLocator.getService(GroupService.class);
		Group group = groupService.getGroupByNamespaceCodeAndName("KC-WKFLW", "OSPADMIN");
		if(currentUser!=null && group!=null){
			return groupService.isMemberOfGroup(currentUser.getPrincipalId(), group.getId());
		}else{
			return false;
		}
    }

}
