package org.kuali.coeus.common.dbfunctionmanager;

import java.util.List;

public interface DbFunctionExecuteService {
	
	public String executeFunction(String packageName,String functionName,List<Object> params);

	
	public String executeFunction(String functionName, List<Object> params);
}
