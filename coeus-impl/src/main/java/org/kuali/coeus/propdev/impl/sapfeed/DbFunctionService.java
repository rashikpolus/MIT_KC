package org.kuali.coeus.propdev.impl.sapfeed;

import java.util.List;

public interface DbFunctionService {
	
	public String executeFunction(String packageName,String functionName,List<Object> params);

	
	public String executeFunction(String functionName, List<Object> params);
}
