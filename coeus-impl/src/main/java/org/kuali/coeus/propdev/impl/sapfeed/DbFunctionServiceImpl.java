package org.kuali.coeus.propdev.impl.sapfeed;

import java.util.List;

import org.kuali.coeus.common.impl.krms.StoredFunctionDao;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.springframework.stereotype.Component;

@Component("dbFunctionService")
public class DbFunctionServiceImpl implements DbFunctionService {

	@Override
	public String executeFunction(String packageName,String functionName,List<Object> params) {
        if(packageName!=null) {
            functionName = packageName+"."+functionName;
        }
        return callFunction(functionName,params);
    }
    
    private String callFunction(String functionName, List<Object> orderedParamValues) {
        StoredFunctionDao storedFunctionDao = getStoredFucntionDao();
        return storedFunctionDao.executeFunction(functionName, orderedParamValues);
    }
    private StoredFunctionDao getStoredFucntionDao() {
        return KcServiceLocator.getService(StoredFunctionDao.class);
    }
    
    @Override
	public String executeFunction(String functionName,List<Object> params) {
        return callFunction(functionName,params);
    }
}
